//
// Created by Wavjaby on 2026/3/26.
//

#include "if.h"

#include <WJCL/string/wjcl_string.h>

#include "lib/code_gen.h"
#include "compiler_util.h"

inline bool code_if(Object* src) {
    //   if/else block 結構見 LLVM_IR_CHEATSHEET.md §if / elseif / else 結構
    //compilerLog("[if]code_if\n");
    compilerLog("> (if)\n");

    //   1. 取得條件運算元字串
    char regName[MAX_NAME_LENGTH];
    Object regSrc = object_nameLiteralOrLoadReg(src, regName, MAX_NAME_LENGTH);
    if (regSrc.type == OBJECT_TYPE_UNDEFINED) goto FAILED;

    {
        //   2. 推入新 scope，初始化 elseifCount 與 containsElse
        const IfInfo ifInfo = {.elseifCount = 0, .containsElse = false};
        ScopeData* scope = scope_pushType(SCOPE_IF_STMT);
        scope->u.ifInfo = (IfInfo){.elseifCount = 0, .containsElse = false};
        // scope_pushId 已經印了 log，不需要再印
        //   3. 輸出條件跳轉 IR，依 scope->id 命名 true/false 兩個 label
        //   4. 輸出 true label（用 buffPrintlnS）
        buffPrintln(&ctx->code, "br i1 %s, label %%if%d.true, label %%if%d.false",
                    regName, scope->id, scope->id);
        buffPrintlnS(&ctx->code, "if%d.true:", scope->id);
    }
    //   5. 清理 Object，return false
    if (src->type == OBJECT_TYPE_SYMBOL || src->type == OBJECT_TYPE_REGISTER) object_free(&regSrc);
    return false;

FAILED:
    return true;
}

inline bool code_elseIfLabel() {
    //compilerLog("[if]code_elseIfLabel\n");
    // TODO: 結束前一個 if/elseif 分支，準備進入下一個 elseif
    //   1. 輸出無條件跳轉到 endif label
    //   2. 輸出前一段的 false label（第一次是 if.false，之後是 elseif<n>.false）
    //   3. 更新 elseifCount
    //   label 命名規則見 LLVM_IR_CHEATSHEET.md §if / elseif / else 結構
    const ScopeData* scope = scope_peek();
    const int id = scope->id;
    const int elseifCount = scope->u.ifInfo.elseifCount;

    // 1. 結束前一個分支，跳到 endif
    buffPrintln(&ctx->code, "br label %%if%d.endif", id);

    // 2. 輸出前一段的 false label
    if (elseifCount == 0)
        buffPrintlnS(&ctx->code, "if%d.false:", id);
    else
        buffPrintlnS(&ctx->code, "if%d.elseif%d.false:", id, elseifCount);

    return false;
}

inline bool code_elseIf(Object* src) {
    //compilerLog("[if]code_elseIf\n");
    // TODO: 彈出當前 scope，推入同 id 的新 scope，繼續累積 elseifCount
    //   1. 從舊 scope 取出 scopeId 與 elseifCount，scope_dump()
    //   2. scope_pushId 推入同 id 的新 scope，elseifCount + 1
    //   3. 取得條件運算元字串，輸出條件跳轉 IR（true/false label 含 elseifCount）
    //   4. 輸出 elseif true label，清理 Object，return false
    // 1. 取出舊 scope 資訊
    const int id = scope_peek()->id;
    const int elseifCount = scope_peek()->u.ifInfo.elseifCount;
    scope_dump();

    compilerLog("> (else if)\n");

    // 2. 推入同 id 的新 scope
    ScopeData* scope = scope_pushId(SCOPE_IF_STMT, id);
    scope->u.ifInfo = (IfInfo){.elseifCount = elseifCount + 1, .containsElse = false};

    // 3. 取得條件運算元字串，輸出條件跳轉
    char regName[MAX_NAME_LENGTH];
    Object regSrc = object_nameLiteralOrLoadReg(src, regName, MAX_NAME_LENGTH);
    if (regSrc.type == OBJECT_TYPE_UNDEFINED) goto FAILED;

    buffPrintln(&ctx->code, "br i1 %s, label %%if%d.elseif%d.true, label %%if%d.elseif%d.false",
                regName, id, elseifCount + 1, id, elseifCount + 1);

    // 4. 輸出 elseif true label
    buffPrintlnS(&ctx->code, "if%d.elseif%d.true:", id, elseifCount + 1);

    if (src->type == OBJECT_TYPE_SYMBOL || src->type == OBJECT_TYPE_REGISTER) object_free(&regSrc);
    return false;

FAILED:
    return true;
}

inline bool code_else() {
    //compilerLog("[if]code_else\n");
    // TODO: 切換 scope 並輸出 else 的進入標籤
    //   1. 取出當前 scope 資訊後 scope_dump()
    //   2. 輸出無條件跳轉到 endif，再輸出前一段的 false label
    //   3. scope_pushId 推入同 id 的新 scope，設 containsElse=true
    //   label 命名規則同 code_elseIfLabel，見 LLVM_IR_CHEATSHEET.md
    const int id = scope_peek()->id;
    const int elseifCount = scope_peek()->u.ifInfo.elseifCount;


    // 輸出跳到 endif，再輸出前一段的 false label
    buffPrintln(&ctx->code, "br label %%if%d.endif", id);


    if (elseifCount == 0)
        buffPrintlnS(&ctx->code, "if%d.false:", id);
    else
        buffPrintlnS(&ctx->code, "if%d.elseif%d.false:", id, elseifCount);
    scope_dump();
    compilerLog("> (else)\n");

    // 推入同 id 的新 scope，設 containsElse=true
    ScopeData* scope = scope_pushId(SCOPE_IF_STMT, id);
    scope->u.ifInfo = (IfInfo){.elseifCount = elseifCount, .containsElse = true};

    return false;
}

inline bool code_ifEnd() {
    //compilerLog("[if]code_ifEnd\n");
    // TODO: 根據 scope 狀態輸出 if 結尾 IR，彈出 scope
    //   三種情況各自需要不同的 label 組合（見 LLVM_IR_CHEATSHEET.md §if 結構圖）：
    //   - 有 else：本體結束後跳 endif，endif label 作為匯合點
    //   - 無 else 無 elseif：本體結束後直接落到 false label
    //   - 有 elseif 無 else：最後一個 elseif 的 false label + endif 匯合點
    //   最後 scope_dump()
    const ScopeData* scope = scope_peek();
    const int id = scope->id;
    const bool containsElse = scope->u.ifInfo.containsElse;
    const int elseifCount = scope->u.ifInfo.elseifCount;

    if (containsElse) {
        buffPrintln(&ctx->code, "br label %%if%d.endif", id);
        scope_dump();
        buffPrintlnS(&ctx->code, "if%d.endif:", id);
    } else if (elseifCount == 0) {
        /* 無 else 無 elseif：直接落到 false label */
        buffPrintln(&ctx->code, "br label %%if%d.false", id);
        scope_dump();
        buffPrintlnS(&ctx->code, "if%d.false:", id);
    } else {
        /* 有 elseif 無 else */
        buffPrintln(&ctx->code, "br label %%if%d.endif", id);
        buffPrintlnS(&ctx->code, "if%d.elseif%d.false:", id, elseifCount);
        scope_dump();
        buffPrintlnS(&ctx->code, "if%d.endif:", id);
    }
    buffPrintln(&ctx->code, "");

    compilerLog("< (if end)\n");
    return false;
}
