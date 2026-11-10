String readWebBusinessGroupId() {
  return const String.fromEnvironment('BUSINESS_GROUP', defaultValue: 'im');
}
