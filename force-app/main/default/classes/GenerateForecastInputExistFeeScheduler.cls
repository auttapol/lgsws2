global class GenerateForecastInputExistFeeScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        database.executebatch(new GenerateForecastInputExistFeeBatch(), 500);
    }
}