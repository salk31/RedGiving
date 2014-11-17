public class SourceAdapterFactory {

  public class SomeException extends Exception {
   
  }

  public SourceAdapter createInstance(SSSCsvRow sampleRow) {
    // XXX put column names for each SourceAdapter so can check has all of them?
    if (sampleRow.hasColumn('JustGiving Transaction Fee Amount')) {
      return new JustGivingAdapter();
    } else if (sampleRow.hasColumn('donor code 1 label')) {
      return new VirginMoneyGivingAdapter();
    } else if (sampleRow.hasColumn('Tribute')) {
      return new MuchLovedAdapter();
    }
    throw new SomeException('Unable to detect type of CSV file.' + sampleRow.headingToIndex);
  }
}