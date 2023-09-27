// import 'package:flutter/material.dart';

// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:baheej/bloc/bloc.dart';
// import 'package:baheej/bloc/payment/payment_bloc.dart';

// class CardPayment extends StatelessWidget {
//   const CardPayment({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment with Credit Card'),
//       ),
//       body: BlockBuilder<PaymentBloc, PaymentState>(
//         padding: const EdgeInsets.all(20), // Add a comma here
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('Card Form', style: Theme.of(context).textTheme.headline5),
//             const SizedBox(height: 20),
//             CardFormField(
//               controller: CardFormEditController(),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(onPressed: () {}, child: const Text('pay')),
//           ],
//         ),
//       ),
//     );
//   }
// }
