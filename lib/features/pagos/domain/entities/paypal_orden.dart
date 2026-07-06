import 'package:equatable/equatable.dart';

class PaypalOrden extends Equatable {
  final String orderId;
  final String approveUrl;

  const PaypalOrden({required this.orderId, required this.approveUrl});

  @override
  List<Object?> get props => [orderId, approveUrl];
}
