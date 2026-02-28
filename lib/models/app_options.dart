const driverGenderOptions = ['male', 'female'];

const tripEventCategories = [
  'Sport',
  'Concert',
  'School Event',
  'Conference',
  'Holiday',
  'Airport Run',
  'Other',
];

String formatDriverGender(String? value) {
  switch (value) {
    case 'male':
      return 'Male';
    case 'female':
      return 'Female';
    default:
      return 'Any';
  }
}
