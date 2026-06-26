//
// Created by WavJaby on 2026/3/2.
//

#include "value_data.h"
#include "lib/code_gen.h"
#include <string.h>

#include "compiler_util.h"

// linkedList_init / linkedList_addp / linkedList_deleteNode / linkedList_freeA / cloneStruct 用法：見 README.md §工具函式速查
bool object_ValueDataListCreate(ObjectType valueType, const ScientificNotation* count, ValueData* valueData) {
    //compilerLog("[debug]object_ValueDataListCreate\n");
    linkedList_init(&valueData->valueList);
    valueData->valueType = valueType;
    valueData->count = (count != NULL) ? sciToInt32(count) : 1;
    if(valueData->count <= 0) {
        yyerrorf("[value_data]竊以為陣列長度、變數數量應為正數，而非%d)\n", valueData->count);
        return true;
    }
    // TODO: 驗證 count > 0，負數應呼叫 yyerrorf 並回傳 true
    return false;
}

bool object_ValueDataListAdd(ValueData* valueData, const Object* obj, const YYLTYPE* tokenLoc) {
    //compilerLog("[debug]object_ValueDataListAdd\n");
    ObjectType objValueType = obj->type;
    if (obj->type == OBJECT_TYPE_SYMBOL && obj->value.symbol) { //引用變數
        objValueType = obj->value.symbol->type;
    }
    if (obj->type == OBJECT_TYPE_REGISTER && obj->value.symbol) { //運算結果
    objValueType = obj->value.symbol->type;
    }

    // AUTO 型別應在此時確定（若容器是 AUTO，由第一個元素決定型別）
    if (valueData->valueType == OBJECT_TYPE_AUTO) {
        valueData->valueType = objValueType;
    }

    // 檢查數量上限：超過 count 上限應報錯
    // 依據速查表，LinkedList 內有 length 欄位
    if (valueData->valueList.length >= valueData->count) {
        yyerrorf("[value_data]valueData->valueList.length(%d)已大於valueData->count(%d)\n", valueData->valueList.length, valueData->count);
        return true;
    }

    // 型別相容性檢查（比對確定後的型別）
    if (valueData->valueType != objValueType && valueData->valueType != OBJECT_TYPE_STR) {
        yyerrorf("[value_data]型別不相容 : %d / %d\n", valueData->valueType, objValueType);
        return true;
    }


    Object* clone = cloneStruct(Object, obj);
    //compilerLog("[debug] type=%d fraction=%lld exp=%d\n", clone->value.number->type, clone->value.number->fraction, clone->value.number->exp);
    // TODO: 型別相容性檢查（objValueType 與 valueData->valueType 比對）
    //       AUTO 型別應在此時確定；超過 count 上限應報錯
    if (obj->type == OBJECT_TYPE_STR && obj->value.str)
        clone->value.str = strdup(obj->value.str);
    linkedList_addp(&valueData->valueList, 0, clone); // freeFlag=0：不自動 free，由 freeA(free) 統一釋放
    return false;
}

bool object_ValueDataListAddDefaults(ValueData* valueData, const YYLTYPE* tokenLoc) {
    //compilerLog("[debug]object_ValueDataListAddDefaults\n");
    // TODO: 根據 valueData->valueType，為剩餘空位（count - 已有元素數）補上各型別的零值
    //       使用對應的 object_create* 建值，再呼叫 object_ValueDataListAdd 加入
    while (valueData->valueList.length < valueData->count) {
        Object defaultObj;
        switch (valueData->valueType) {
            case OBJECT_TYPE_I32:
            case OBJECT_TYPE_NUM: {
                ScientificNotation zeroNum = {.type = I32, .fraction = 0, .fractionLen = 1, .exp = 0};
                defaultObj = object_createNumber(&zeroNum);
                break;
            }
            case OBJECT_TYPE_I64: {
                ScientificNotation zeroNum = {.type = I64, .fraction = 0, .fractionLen = 1, .exp = 0};
                defaultObj = object_createNumber(&zeroNum);
                break;
            }
            case OBJECT_TYPE_BOOL: {
                defaultObj = object_createBool(false);
                break;
            }
            case OBJECT_TYPE_STR: {
                defaultObj = object_createStrConst("");
                break;
            }
            case OBJECT_TYPE_ARRAY: {
                defaultObj = object_createArray();
                break;
            }
            default:
                yyerrorf("[value_data]valueData->valueType type%d不是可補齊的型別\n", valueData->valueType);
                return true;
        }
        //compilerLog("[debug] type=%d fraction=%lld exp=%d\n", defaultObj.value.number->type, defaultObj.value.number->fraction, defaultObj.value.number->exp);
        if (object_ValueDataListAdd(valueData, &defaultObj, tokenLoc)) {
            yyerrorf("[value_data]AddDefault途中ListAdd報錯\n");
            return true;
        }
    }
    return false;
}

Object* object_ValueDataListPop(ValueData* valueData) {
    //compilerLog("[object] object_ValueDataListPop\n");
    if (valueData->valueList.length == 0)
        return NULL;
    LinkedListNode* node = valueData->valueList.head->next;
    Object* obj = node->value;
    linkedList_deleteNode(&valueData->valueList, node);
    return obj;
}

bool object_ValueDataListFree(ValueData* valueData) {
    linkedList_freeA(&valueData->valueList, free);
    return false;
}
