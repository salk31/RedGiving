public interface SourceContactAdapter {

  Boolean isDoNotCall();

  Boolean hasOptedOutOfEmail();

  void updateContact(Contact contact);
}