/// Esegue uno xor logico fra [first] e [second]
// ignore: avoid_positional_boolean_parameters
bool xor(bool first, bool second) => (first || second) && !(first && second);
