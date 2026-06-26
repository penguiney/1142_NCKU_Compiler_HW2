#include "expression.h"

#include "lib/code_gen.h"
#include "compiler_util.h"
#include "object.h"
#include "scope.h"

static inline bool object_sameRegister(const Object* a, const Object* b) {
    //compilerLog("[Expression] object_sameRegister\n");
    return a->type == OBJECT_TYPE_REGISTER && b->type == OBJECT_TYPE_REGISTER &&
        a->value.symbol->index == b->value.symbol->index;
}

static inline bool isExpressionOperationLegal(const ExpOp eop, const ObjectType targetType) {
    //compilerLog("[Expression] isExpressionOperationLegal\n");
    if (ExpOp_isArithmetic(eop) && !ObjectType_isNumber(targetType)) {
        if (eop == OP_ADD && targetType == OBJECT_TYPE_STR) {
            // String concatenation is legal
        } else {
            yyerrorf("運算符號『%s』不適用於『%s』之屬\n", expOp2str[eop], objectType2str[targetType]);
            return false;
        }
    }
    if (ExpOp_isBooleanOnly(eop) && targetType != OBJECT_TYPE_BOOL) {
        yyerrorf("運算符號『%s』不適用於『%s』之屬\n", expOp2str[eop], objectType2str[targetType]);
        return false;
    }
    if (eop == OP_MOD && !ObjectType_isInteger(targetType)) {
        yyerrorf("運算符號『%s』不適用於『%s』之屬\n", expOp2str[eop], objectType2str[targetType]);
        return false;
    }
    return true;
}

Object code_expression(const ExpOp eop, const bool opLeft, Object* a, Object* b,
                       const YYLTYPE* aLoc, const YYLTYPE* bLoc) {
    //compilerLog("[Expression] code_expression\n");
    ObjectType aValueType = object_getValueType(a), bValueType = object_getValueType(b);

    const ObjectType targetType = object_getPromotedType(aValueType, bValueType);

    // TODO: 實作二元運算式 IR 生成，完成後回傳 OBJECT_TYPE_REGISTER Object
    //   1. 分配結果暫存器（型別視運算子是否輸出布林而定）
    //   2. 驗證運算子與型別合法（isExpressionOperationLegal）
    //   3. 取得兩側運算元字串，注意 opLeft 決定 a/b 的左右方向
    //   4. 根據型別（整數/浮點）選擇對應的 IR opcode（opIRIntNames / opIRFloatNames）
    //   5. 輸出 IR 指令；字串加法需呼叫 runtime 函式而非算術指令
    //      可用的 IR opcode 與 runtime 函式見 LLVM_IR_CHEATSHEET.md
    //   6. 清理 Object，回傳 REGISTER Object
    // 1. 分配結果暫存器
    const bool isBoolResult = ExpOp_isOutputLogic(eop) || ExpOp_isBooleanOnly(eop);
    const ObjectType resultType = isBoolResult ? OBJECT_TYPE_BOOL : targetType;
    const SymbolData resultSymbol = object_createRegisterSymbol(resultType);

    // 2. 驗證合法性
    if (!isExpressionOperationLegal(eop, targetType)) goto FAILED;

    {
        // 3. 取得兩側運算元字串
        char regNameA[MAX_NAME_LENGTH], regNameB[MAX_NAME_LENGTH];
        Object regA = object_nameLiteralOrLoadReg(a, regNameA, MAX_NAME_LENGTH);
        if (regA.type == OBJECT_TYPE_UNDEFINED) goto FAILED;
        Object regB = object_nameLiteralOrLoadReg(b, regNameB, MAX_NAME_LENGTH);
        if (regB.type == OBJECT_TYPE_UNDEFINED) goto FAILED;

        // opLeft=true 表示「於」，a 是右側，b 是左側
        const char* left  = opLeft ? regNameB : regNameA;
        const char* right = opLeft ? regNameA : regNameB;

        const char* llvmTypeName = objectType2llvmType[targetType];

        // 4. 選擇 IR opcode
        const char* opcode = ObjectType_isFloat(targetType)
            ? opIRFloatNames[eop]
            : opIRIntNames[eop];
   
        buffPrintln(&ctx->code, "%%reg%s = %s %s %s, %s", resultSymbol.name, opcode, llvmTypeName, left, right);

        // 輸出verpose
        compilerLog("exp %s %s %s -> reg<%s>\n", object_print(opLeft ? b : a), opDebugNames[eop], object_print(opLeft ? a : b), objectType2str[resultType]);
        
        if (b->type == OBJECT_TYPE_SYMBOL) object_free(&regB);
    }

    // 6. 清理並回傳
    if (!object_sameRegister(a, b)) object_free(a);
    object_free(b);
    return (Object){
        .type = OBJECT_TYPE_REGISTER,
        .value.symbol = cloneStruct(SymbolData, &resultSymbol)
    };

FAILED:
    if (!object_sameRegister(a, b)) object_free(a);
    object_free(b);
    return (Object){.type = OBJECT_TYPE_UNDEFINED, .value = {}};
}

Object code_expressionMod(ExpOp dop, ExpOp eop, bool op_left, Object* a, Object* b,
                          YYLTYPE* dopLoc, YYLTYPE* eopLoc) {
    //compilerLog("[Expression] code_expressionMod\n");
    if (dop != OP_DIV) {
        yyerrorf("欲問所餘，必先用除\n");
        goto FAILED;
    }
    return code_expression(eop, op_left, a, b, dopLoc, eopLoc);

FAILED:
    if (!object_sameRegister(a, b)) object_free(a);
    object_free(b);
    return (Object){.type = OBJECT_TYPE_UNDEFINED, .value = {}};
}

Object code_expressionChain(ExpOp eop, bool op_left, Object* a, Object* b,
                            YYLTYPE* aLoc, YYLTYPE* bLoc) {
    //compilerLog("[Expression] code_expressionChain\n");
    return code_expression(eop, op_left, a, b, aLoc, bLoc);
}

Object code_expressionChainMod(ExpOp dop, ExpOp eop, bool op_left, Object* a, Object* b,
                               YYLTYPE* dopLoc, YYLTYPE* eopLoc) {
    //compilerLog("[Expression] code_expressionChainMod\n");
    if (dop != OP_DIV) {
        yyerrorf("欲問所餘，必先用除\n");
        object_free(a);
        object_free(b);
        return (Object){.type = OBJECT_TYPE_UNDEFINED, .value = {}};
    }
    return code_expressionChain(eop, op_left, a, b, dopLoc, eopLoc);
}
