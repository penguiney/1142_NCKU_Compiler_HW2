//
// Created by WavJaby on 2026/03/26.
//

#include "for.h"

#include <WJCL/string/wjcl_string.h>

#include "lib/code_gen.h"
#include "compiler_util.h"

bool code_forLoop(Object* src) {
    if (src->type == OBJECT_TYPE_UNDEFINED)
        goto FAILED;

    compilerLog("> (for loop, count: %s)\n", object_print(src));

    // TODO: 實作 for 迴圈 IR 生成
    //   1. 推入新 scope，取得計數運算元字串（需升級到 I32）
    //   2. 依 src->type 設定 scope->u.forLoop.symbol（記錄計數器型別）
    //   3. 輸出 entry → header → phi → icmp → 條件跳轉 → body label 的完整 IR 序列
    //   完整 block 結構與各 label 命名規則見 LLVM_IR_CHEATSHEET.md §phi 節點（for 迴圈）
    {
        // 1. 推入新 scope
        ScopeData* scope = scope_pushType(SCOPE_FOR_LOOP);
        const int id = scope->id;

        // 取計數運算元字串（升級到 I32）
        char countReg[MAX_NAME_LENGTH];
        Object regSrc = object_loadRegAndPromote(src, OBJECT_TYPE_I32, countReg, MAX_NAME_LENGTH);
        if (regSrc.type == OBJECT_TYPE_UNDEFINED) goto FAILED;

        // 2. 記錄計數器型別
        scope->u.forLoop.symbol = (SymbolData){.type = OBJECT_TYPE_I32};
        const char* type = objectType2llvmType[OBJECT_TYPE_I32];

        // 3. 輸出 IR 序列
        buffPrintln(&ctx->code, "br label %%loop%d.entry", id);
        buffPrintlnS(&ctx->code, "loop%d.entry:", id);
        buffPrintln(&ctx->code, "br label %%loop%d.header", id);
        buffPrintlnS(&ctx->code, "loop%d.header:", id);
        buffPrintln(&ctx->code, "%%loop%d.i = phi %s [ 0, %%loop%d.entry ], [ %%loop%d.i.next, %%loop%d.update ]",
                    id, type, id, id, id);
        buffPrintln(&ctx->code, "%%loop%d.cond = icmp slt %s %%loop%d.i, %s",
                    id, type, id, countReg);
        buffPrintln(&ctx->code, "br i1 %%loop%d.cond, label %%loop%d.body, label %%loop%d.exit",
                    id, id, id);
        buffPrintlnS(&ctx->code, "loop%d.body:", id);

        if (src->type == OBJECT_TYPE_SYMBOL) object_free(&regSrc);
    }
FAILED:
    object_free(src);
    return true;
}

bool code_forLoopEnd(Object* obj) {
    // TODO: 輸出迴圈 update/exit IR，彈出 scope
    //   輸出 update label → 計數器遞增 → 跳回 header → exit label
    //   IR 指令與 label 命名規則見 LLVM_IR_CHEATSHEET.md §phi 節點（for 迴圈）
    const ScopeData* scope = scope_peek();
    const int id = scope->id;
    const char* type = objectType2llvmType[scope->u.forLoop.symbol.type];

    buffPrintln(&ctx->code, "br label %%loop%d.update", id);
    buffPrintlnS(&ctx->code, "loop%d.update:", id);
    buffPrintln(&ctx->code, "%%loop%d.i.next = add nsw %s %%loop%d.i, 1", id, type, id);
    buffPrintln(&ctx->code, "br label %%loop%d.header", id);
    buffPrintlnS(&ctx->code, "loop%d.exit:", id);
    buffPrintln(&ctx->code, "");

    scope_dump();
    compilerLog("< (for loop end)\n");
    return false;
}
