import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/services/base_url.dart';
import 'package:warsha_commerce/services/orders_service.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/date.dart';
import 'package:warsha_commerce/utils/default_footer.dart';
import 'package:warsha_commerce/view_models/order_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/orders/pdf_view.dart';
import 'package:warsha_commerce/views/shopping_cart/container_style.dart';

class OrdersHistory extends StatelessWidget {
  const OrdersHistory({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(create: (context) => OrderVM(
      context.read<OrdersService>(),
      context.read<UserViewModel>(),
    ),
      child: Consumer<OrderVM>(
      builder: (context, orderVM, child) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF222222),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "طلباتي السابقة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: orderVM.isLoading || orderVM.ordersList == null ? const CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ) : orderVM.ordersList!.isEmpty ? Center(child: StyledContainer(
              padding: const EdgeInsets.all(100),
              child: Text("لا يوجد طلبات سابقة حتي الان. نحن بانتظار اولي الطلبات"),
            )) : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    itemCount: orderVM.ordersList?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return OrderHistoryCard(index: index, orderVM: orderVM,);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 20);
                    },
                  ),
                  const DefaultFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final int index;
  final OrderVM orderVM;

  const OrderHistoryCard({super.key, required this.index, required this.orderVM});

  String getStatus(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return "قيد الانتظار";
      case "processing":
        return "جاري تحضير طلبك";
      case "shipped":
        return "تم الشحن";
      case "completed":
        return "تم التوصيل";
      case "cancelled":
        return "ملغي";
      default:
        return status; // Returns the original string if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                " طلب رقم #${orderVM.ordersList![index].orderId}  ",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildStatusChip(context, getStatus(orderVM.ordersList![index].status!)),
            ],
          ),
          const Divider(height: 30),

          _historyRow("التاريخ", DateHelper.formatDatePicker(orderVM.ordersList![index].orderDate.toString())),
          const SizedBox(height: 10),
          _historyRow("إجمالي المبلغ", "${orderVM.ordersList![index].totalPrice} جنيه "),
          const SizedBox(height: 10),
          _historyRow("عدد المنتجات", "${orderVM.ordersList![index].orderItems.length}"),

          const SizedBox(height: 20),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewPage(
                      pdfPath: "${Baseurl.invoiceAPI}/${orderVM.ordersList![index].orderId}"),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: Constants.BORDER_RADIUS_5,
              ),
              child: Center(
                child: Text(
                  "عرض الفاتورة",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    bool isDone = status == "تم التوصيل";
    bool isCancelled = status == "ملغي";
    bool isProcessing = status == "جاري تحضير طلبك";
    bool isShipped = status == "تم الشحن";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.withAlpha(30) : isProcessing ? Colors.blue.withAlpha(30) : isShipped ? Colors.black.withAlpha(30) : isCancelled ? Colors.red.withAlpha(30) : Colors.orange.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isDone ? Colors.green : isProcessing ? Colors.blue : isShipped ? Colors.black : isCancelled ? Colors.red : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}