global class ForecastExpireDrawdownBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        database.executebatch(new ForecastExpireDrawdownBatch(Date.newInstance(Date.today().addMonths(-1).year(), Date.today().addMonths(-1).month(), 1)), 500);
    }
}