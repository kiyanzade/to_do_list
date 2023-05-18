void main() {
getData(4).then((value) => print(value));
print(getData(2));
print('main fun');

}

Future<int> getData(int a)async {
  await Future.delayed(Duration(seconds: a));
  print('getData: '+a.toString());
  return Future(() => a);
}
