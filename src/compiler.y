/* Definition section */
%code requires {
    # define YYLTYPE_IS_DECLARED 1
    # define YYLTYPE_IS_TRIVIAL 1
}

%{
    #include "compiler_util.h"
    #include "main.h"
    #include "expression.h"
    #include "value_data.h"
    #include "scope.h"
    #include "control/for.h"
    #include "control/if.h"
    #include "control/while.h"
    #include "control/function.h"
%}

%define parse.error custom
%locations

/* Variable or self-defined structure */
%union {
    ObjectType var_type;

    bool b_var;
    ScientificNotation n_var;
    char *s_var;

    Object obj_val;
    ValueData val_data;

    FuncCallInfo* func_call;

    bool exp_left;
    ExpOp exp_op;
}
/* Token — quick start 最小集合，實作各規則時依需要自行補充 */
%token COMMENT
%token HERE_ARE HERE_IS_A SAID NAME_IT PAST TOPIC SET ITS IS_THUS
%token IF ELSE_IF ELSE FOR TIMES WHILE_TRUE BREAK END
%token INDEX PUSH LENGTH THOSE TAKE 
%token PRINT TO_CALL
%token RETURN

%token <n_var> NUMBER_LIT
%token <b_var> BOOL_LIT
%token <var_type> VAR_TYPE
%token <var_type> VAR_TYPE_FUNC
%token <s_var> STR_LIT IDENT
%token <exp_op> EXP_MATH_OP EXP_MATH_MOD_OP EXP_LOGIC_OP EXP_BINARY_LOGIC_OP 
%token <exp_left> EXP_PREPOSITION

/* %left 範例 — ValueStmt 實作時視衝突補充 */
%left INDEX

/* Nonterminal with return — 實作子規則時依需要自行補充 */
%type <val_data> CreateValueDataListStmt
%type <obj_val> ValueLiteralStmt VariableStmt NoSaidLitOrVarStmt LitOrVarStmt MultiLitOrVarStmt 
%type <obj_val> ExpressionStmt ExpressionChainStmt ValueStmt

/* For Return — 用於已提供的 ReturnStmt，詳見 YACC_CHEATSHEET.md §優先序宣告 */
%nonassoc LOWER_THAN_EXPR
%nonassoc RETURN

/* Yacc will start at this nonterminal */
%start Program
%%
/* Grammar section */

/* Scope */
Program
    : GlobalScopeStmt
;

GlobalScopeStmt
    : BodyListStmt
;

/* Scope Body */
BodyListStmt
    : BodyListStmt BodyStmt
    |
;

BodyStmt
    : COMMENT STR_LIT
    | OperationStmt
    | ConditionStmt
    | FunctionStmt
;

/* Function */
/* TODO: 函式定義
 * 登錄函式符號、推入 context/scope、逐一登錄參數、結束後彈出。
 * 函式：func_define, func_defineBody, func_defineBodyEnd, func_defineAddParam
 * 注意：參數型別需透過 $<var_type>0 跨規則傳遞；參數列與參數名稱各自是一層規則
 */
FunctionStmt
    :
;

FunctionArgsStmt
    :
;

FunctionArgListStmt
    :
;

/* Condition and Operation */
/* TODO: 控制流（FOR / WHILE / IF-ELSEIF-ELSE）
 * 三種分支，每種都有對應的開始與結束 IR 呼叫。
 * 函式：code_forLoop/End, code_whileLoopStart/End, code_if, code_elseIfLabel, code_elseIf, code_else, code_ifEnd
 * 注意：else-if 與 else 皆為可選；IF 結構由三個子規則組成
 */
ConditionStmt
    : IF ExpressionStmt TOPIC { yylloc = @3; code_if(&$2); } BodyListStmt IfEndStmt
    | WHILE_TRUE { code_whileLoopStart(); } BodyListStmt END { code_whileLoopEnd(NULL); }
    | FOR ValueStmt TIMES { code_forLoop(&$2); } BodyListStmt END { code_forLoopEnd(NULL); }
    | BREAK { code_break(&@1); }
;

IfEndStmt
    : END { code_ifEnd(); }
    | ELSE { code_else(); } BodyListStmt END { code_ifEnd(); }
    | ElseIfStmt
;

ElseIfStmt
    : ELSE_IF { code_elseIfLabel(); } ExpressionStmt TOPIC { code_elseIf(&$3); } BodyListStmt IfEndStmt
;

/* TODO: 各種操作語句
 * 涵蓋變數宣告、命名、賦值、函式呼叫、陣列 push、印出、return、break。
 * 函式：object_ValueDataList*, code_createVariable, code_assign, code_stdoutPrint,
 *       code_arrayPush, code_return, code_returnValue, code_break,
 *       func_callInit, func_callArgAdd, func_call, func_takeAndCall
 * 注意：函式呼叫分前置（施）與後置（以施）兩種；mid-rule action 用 $0 傳遞中間值；
 *       呼叫結果後可接命名、return、print 或省略
 * 位置參數：code_return/code_returnValue/code_break 都多一個 tokenLoc 參數，
 *       呼叫時記得帶 RETURN/BREAK 那個 token 自己的 @N（例如 &@1），
 *       不要省略——規則 reduce 前可能已經往後看了一個 token，
 *       全域 yylloc 屆時會指到下一句而非這個 token 自己的位置
 */
OperationStmt
    : CreateValueDataListStmt { $<val_data>$ = $1; } MultiLitOrVarStmt { object_ValueDataListAddDefaults(&$<val_data>2, &@1); $<val_data>$ = $<val_data>2; } EndStmt
    | PAST IDENT TOPIC SET NoSaidLitOrVarStmt IS_THUS { Object dest = scope_findSymbol($<s_var>2); code_assign(&dest, &$5); }
    | ExpressionChainStmt { ctx->last_result = $1; } ExpressionNextStmt
    | ExpressionChainStmt PAST IDENT TOPIC SET ITS IS_THUS {yylloc = @3; Object dest = scope_findSymbol($<s_var>3); code_assign(&dest, &$1); }
    | THOSE VariableStmt INDEX VariableStmt { ctx->last_result = object_getIndex(&$2, &$4, &@2, &@4); } ExpressionNextStmt
    | PUSH VariableStmt PushStmt
    | THOSE VariableStmt LENGTH PRINT {Object leng = code_getLength(&$2, &@1); code_stdoutPrintObject( &leng, false, true);}
;

CreateValueDataListStmt
    : HERE_IS_A VAR_TYPE { object_ValueDataListCreate($<var_type>2, NULL, &$$); }
    | HERE_ARE NUMBER_LIT VAR_TYPE { object_ValueDataListCreate($<var_type>3, &$<n_var>2, &$$); }
    | HERE_IS_A VAR_TYPE NUMBER_LIT { 
        object_ValueDataListCreate($<var_type>2, NULL, &$$);
        ScientificNotation* num = malloc(sizeof(ScientificNotation));
        *num = $<n_var>3;
        Object numObj = object_createNumber(num);
        numObj.type = $<var_type>2;
        object_ValueDataListAdd(&$$, &numObj, &@3);
    }
    | HERE_IS_A VAR_TYPE STR_LIT {
        object_ValueDataListCreate($<var_type>2, NULL, &$$);
        Object strObj = object_createStr($<s_var>3);
        object_ValueDataListAdd(&$$, &strObj, &@3);
    }
;

EndStmt
    : NAME_IT IDENT { code_createVariable(&$<val_data>0, $<s_var>2); $<val_data>$ = $<val_data>0; } RepeatSaidIdentStmt
    | PRINT { code_stdoutPrint(&$<val_data>0, true); }
;

RepeatSaidIdentStmt
    : /* empty */
    | RepeatSaidIdentStmt SAID IDENT { code_createVariable(&$<val_data>0, $<s_var>3); }
;


PushStmt
    : /* empty */
    | PushStmt EXP_PREPOSITION ValueStmt { code_arrayPush(&$<obj_val>0, &$<obj_val>3, &@3); }
;


VariableDefineStmt
    : NAME_IT IDENT { code_createVariable(&$<val_data>0, $<s_var>2); }
    | SAID IDENT { code_createVariable(&$<val_data>0, $<s_var>2); }
;

/* Expressions */
/* TODO: 運算式（四則/邏輯，鏈式）
 * 函式：code_expression/Mod, code_expressionChain/Mod
 * 注意：鏈式第一項用 code_expression，後續用 code_expressionChain；需更新 ctx->last_result
 * 位置參數：aLoc 不是單純「左運算元的位置」，是「整個運算式的起點 token」，
 *       log 跟報錯都靠它定位。大部分規則第一個符號就是起點，直接傳 &@1；
 *       但如果文法是「運算子在前」（例如 乘/加/減 開頭、或 凡/兩者 開頭的二元邏輯），
 *       別把 aLoc 設成運算元的位置，要傳那個開頭運算子/關鍵字自己的 &@1，
 *       否則 verbose log 印出來的位置會偏移
 */
ExpressionChainStmt
    : ExpressionStmt { $$ = $1; ctx->last_result = $1; }
    | ExpressionChainStmt EXP_MATH_OP ITS EXP_PREPOSITION ValueStmt { $$ = code_expressionChain($<exp_op>2, $<exp_left>4, &ctx->last_result, &$5, &@2, &@5); ctx->last_result = $$; }
    | ExpressionChainStmt EXP_MATH_OP ValueStmt EXP_PREPOSITION ITS { $$ = code_expressionChain($<exp_op>2, $<exp_left>4, &$3, &ctx->last_result, &@2, &@5); ctx->last_result = $$; }
    | ExpressionChainStmt EXP_MATH_OP ITS EXP_PREPOSITION ValueStmt EXP_MATH_MOD_OP { $$ = code_expressionChainMod($<exp_op>2, OP_MOD, $<exp_left>4, &ctx->last_result, &$5, &@2, &@6); ctx->last_result = $$; }
;

ExpressionStmt
    : EXP_MATH_OP ValueStmt EXP_PREPOSITION ValueStmt { $$ = code_expression($<exp_op>1, $<exp_left>3, &$2, &$4, &@1, &@4); }
    | EXP_MATH_OP ValueStmt EXP_PREPOSITION ValueStmt EXP_MATH_MOD_OP { $$ = code_expressionMod($<exp_op>1, OP_MOD, $<exp_left>3, &$2, &$4, &@1, &@5); }
    | ValueStmt EXP_LOGIC_OP ValueStmt { $$ = code_expression($<exp_op>2, false, &$1, &$3, &@1, &@3); }
    | THOSE ValueStmt ValueStmt EXP_BINARY_LOGIC_OP { $$ = code_expression($<exp_op>4, false, &$2, &$3, &@1, &@3); }
;

ExpressionNextStmt
    : NAME_IT IDENT {
            ValueData vd;
            object_ValueDataListCreate(object_getValueType(&ctx->last_result), NULL, &vd);
            object_ValueDataListAdd(&vd, &ctx->last_result, &@1);
            code_createVariable(&vd, $<s_var>2);
    }
    | PRINT {code_stdoutPrintObject( &ctx->last_result, false, true);}
;

ValueLiteralOrLastStmt
    :
;

/* Value */
/* TODO: 值、字面值、變數查找
 * 函式：object_createStr/Number/Bool, scope_findSymbol, object_getIndex, code_getLength
 * 注意：ITS 取 ctx->last_result；陣列索引與長度為 ValueStmt 的延伸形式
 */
ValueStmt
    : ValueLiteralStmt { $$ = $1; }
    | VariableStmt     { $$ = $1; }
    | VariableStmt LENGTH { $$ = code_getLength(&$1, &@1); }
;

/* 值區：SAID 後面接字面值或變數，直到遇到 NAME_IT 或 PRINT 為止 */
MultiLitOrVarStmt
    : /* empty */
    | MultiLitOrVarStmt SAID ValueLiteralStmt { object_ValueDataListAdd(&$<val_data>0, &$3, &@3); }
    | MultiLitOrVarStmt SAID VariableStmt { object_ValueDataListAdd(&$<val_data>0, &$3, &@3); }
    | MultiLitOrVarStmt SAID ExpressionStmt { object_ValueDataListAdd(&$<val_data>0, &$3, &@3); }
;

LitOrVarStmt
    : SAID ValueLiteralStmt { $$ = $2; }
    | SAID VariableStmt     { $$ = $2; }
;

NoSaidLitOrVarStmt
    : ValueLiteralStmt { $$ = $1; }
    | VariableStmt     { $$ = $1; }
;

ValueLiteralStmt
    : NUMBER_LIT { $$ = object_createNumber(&$<n_var>1); }
    | BOOL_LIT   { $$ = object_createBool($<b_var>1); }
    | STR_LIT    { $$ = object_createStr($<s_var>1); }
;

VariableStmt
    : IDENT { $$ = scope_findSymbol($<s_var>1); }
;

%%

#include "compiler.h"