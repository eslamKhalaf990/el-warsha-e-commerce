import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/default_footer.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'timeline_stepper.dart';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final timeline = Provider.of<TimelineController>(context, listen: false);
    
    // Check auth to decide starting page (Sign In or Cart)
    timeline.checkAuth(userVM);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF222222),
          leading: Consumer<TimelineController>(
            builder: (context, timeline, child) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (timeline.page > 0) {
                    timeline.previousPage();
                  } else {
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
          title: const Text(
            'سلة التسوق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 900;

              return Column(
                children: [
                  // Fixed Header for Stepper
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: isDesktop ? constraints.maxWidth * 0.1 : 20.0,
                    ),
                    child: const TimelineStepper(),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 32.0,
                          horizontal: isDesktop ? constraints.maxWidth * 0.1 : 16.0,
                        ),
                        child: Consumer<TimelineController>(
                          builder: (context, timeline, child) {
                            return Center(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: Column(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: isDesktop
                                          ? timeline.desktopSteps[timeline.page]
                                          : timeline.mobileSteps[timeline.page],
                                    ),
                                    const DefaultFooter(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
