public with sharing class TriggerDispatcher {
    public static void run(TriggerHandler handler) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) handler.beforeInsert(Trigger.new);
            if (Trigger.isUpdate) handler.beforeUpdate(Trigger.new, Trigger.oldMap);
            if (Trigger.isDelete) handler.beforeDelete(Trigger.old, Trigger.oldMap);
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) handler.afterInsert(Trigger.new);
            if (Trigger.isUpdate) handler.afterUpdate(Trigger.new, Trigger.oldMap);
            if (Trigger.isDelete) handler.afterDelete(Trigger.old, Trigger.oldMap);
            if (Trigger.isUndelete) handler.afterUndelete(Trigger.new);
        }
    }
}