import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class TimelineStepper extends StatelessWidget {
  const TimelineStepper({super.key});

  @override
  Widget build(BuildContext context) {
    // Define animation duration centrally
    const duration = Duration(seconds: 3);

    return Column(
      children: [
        const Text(
          "سلة المشتريات",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          width: double.infinity,
          child: Consumer<TimelineController>(
            builder: (context, timeline, child) {
              final int curPage = timeline.page;

              return Row(
                children: [
                  _animatedStep("1", "تسجيل الدخول", 0, curPage, context, duration, () => timeline.changePage(0)),
                  _animatedDivider(0, curPage, context, duration),
                  _animatedStep("2", "السلة", 1, curPage, context, duration, () => timeline.changePage(1)),
                  _animatedDivider(1, curPage, context, duration),
                  _animatedStep("3", "الدفع", 2, curPage, context, duration, () => timeline.changePage(2)),
                  _animatedDivider(2, curPage, context, duration),
                  _animatedStep("4", "اكتمل", 3, curPage, context, duration, () => timeline.changePage(3)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _animatedStep(
      String number,
      String text,
      int stepIndex,
      int curPage,
      BuildContext context,
      Duration duration,
      VoidCallback onTap,
      ) {
    // Determine if step is interactive
    final userVM = Provider.of<UserViewModel>(context); // Removed listen: false to rebuild on logout/login
    bool isLoggedIn = userVM.token != "-";
    
    bool isActive = curPage == stepIndex;
    // If logged in, the first step is visually "completed"
    bool isCompleted = (isLoggedIn && stepIndex == 0) || curPage > stepIndex;
    
    bool isEnabled = stepIndex <= curPage; 
    
    // Special case: If logged in, don't let them go back to Sign In page
    if (isLoggedIn && stepIndex == 0) {
      isEnabled = false; 
    }

    final colorScheme = Theme.of(context).colorScheme;

    Color circleColor = isActive || isCompleted
        ? colorScheme.tertiary
        : colorScheme.surfaceContainerHighest;

    Color contentColor = isActive || isCompleted
        ? colorScheme.onTertiary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: duration,
              // CHANGED: Use a curve that does not go negative
              curve: Curves.fastOutSlowIn,
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: colorScheme.tertiary.withAlpha(100),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  )
                ]
                    : [], // An empty list interpolates safely with standard curves
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: duration,
                child: isCompleted
                    ? Icon(Iconsax.tick_circle_copy, size: 18, color: contentColor, key: const ValueKey("icon"))
                    : Text(
                  number,
                  key: const ValueKey("text"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: duration,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? colorScheme.tertiary : colorScheme.onSurface,
                fontSize: isActive ? 16 : 14,
              ),
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedDivider(
      int stepIndex,
      int curPage,
      BuildContext context,
      Duration duration,
      ) {
    // The divider is "filled" if the current page has passed this step
    bool isFilled = curPage > stepIndex;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 4, // Thickness of the line
          child: Stack(
            children: [
              // Background Line (Inactive part)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Foreground Line (Animated Fill)
              AnimatedFractionallySizedBox(
                duration: duration,
                curve: Curves.easeInOut,
                widthFactor: isFilled ? 1.0 : 0.0,
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}