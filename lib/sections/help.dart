import 'package:fluent_ui/fluent_ui.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  final List faqData = const [
    // General Questions
    {
      "category": "General Questions",
      "faqs": [
        {
          "question": "How does this app track screen time?",
          "answer": "The app monitors your device's usage in real-time, tracking the time spent on different applications. It provides comprehensive insights into your digital habits, including total screen time, productive time, and application-specific usage."
        },
        {
          "question": "What makes an app 'Productive'?",
          "answer": "You can manually mark apps as productive in the 'Applications' section. Productive apps contribute to your Productive Score, which calculates the percentage of screen time spent on work-related or beneficial applications."
        },
        {
          "question": "How accurate is the screen time tracking?",
          "answer": "The app uses system-level tracking to provide precise measurement of your device usage. It captures foreground time for each application with minimal battery impact."
        },
        {
          "question": "Can I customize my app categorization?",
          "answer": "Absolutely! You can create custom categories, assign apps to specific categories, and easily modify these assignments in the 'Applications' section. This helps in creating more meaningful usage analytics."
        },
        {
          "question": "What insights can I gain from this app?",
          "answer": "The app offers comprehensive insights including Productive Score, usage patterns by time of day, detailed application usage, focus session tracking, and visual analytics like graphs and pie charts to help you understand and improve your digital habits."
        }
      ]
    },
    // Applications Management
    {
      "category": "Applications Management",
      "faqs": [
        {
          "question": "How do I hide specific apps from tracking?",
          "answer": "In the 'Applications' section, you can toggle the visibility of apps."
        },
        {
          "question": "Can I search and filter my applications?",
          "answer": "Yes, the Applications section includes a search functionality and filtering options. You can filter apps by category, productivity status, tracking status, and visibility."
        },
        {
          "question": "What editing options are available for applications?",
          "answer": "For each application, you can edit: category assignment, productivity status, tracking usage, visibility in reports, and set individual daily time limits."
        },
        {
          "question": "How are application categories determined?",
          "answer": "Initial categories are system-suggested, but you have full control to create, modify, and assign custom categories based on your workflow and preferences."
        }
      ]
    },
    // Usage Analytics & Reports
    {
      "category": "Usage Analytics & Reports",
      "faqs": [
        {
          "question": "What types of reports are available?",
          "answer": "Reports include: Total screen time, Productive time, Most used apps, Focus sessions, Daily screen time graph, Category breakdown pie chart, Detailed application usage, Weekly usage trends, and Usage pattern analysis by time of day."
        },
        {
          "question": "How detailed are the application usage reports?",
          "answer": "Detailed application usage reports show: App name, Category, Total time spent, Productivity status, and offer an 'Actions' section with deeper insights like usage summary, daily limits, usage trends, and productivity metrics."
        },
        {
          "question": "Can I analyze my usage trends over time?",
          "answer": "Yes! The app provides week-over-week comparisons, showing graphs of usage over past weeks, average daily usage, longest sessions, and weekly totals to help you track your digital habits."
        },
        {
          "question": "What is the 'Usage Pattern' analysis?",
          "answer": "Usage Pattern breaks down your screen time into morning, afternoon, evening, and night segments. This helps you understand when you're most active on your device and identify potential areas for improvement."
        }
      ]
    },
    // Alerts & Limits
    {
      "category": "Alerts & Limits",
      "faqs": [
        {
          "question": "How granular are the screen time limits?",
          "answer": "You can set overall daily screen time limits and individual app limits. Limits can be configured in hours and minutes, with options to reset or adjust as needed."
        },
        {
          "question": "What notification options are available?",
          "answer": "The app offers multiple notification types: System alerts when you exceed screen time, Frequent alerts at customizable intervals (1, 5, 15, 30, or 60 minutes), and toggles for focus mode, screen time, and application-specific notifications."
        },
        {
          "question": "Can I customize limit alerts?",
          "answer": "Yes, you can customize alert frequency, enable/disable specific types of alerts, and set different limits for overall screen time and individual applications."
        }
      ]
    },
    // Focus Mode & Pomodoro Timer
    {
      "category": "Focus Mode & Pomodoro Timer",
      "faqs": [
        {
          "question": "What types of Focus Modes are available?",
          "answer": "Available modes include Deep Work (longer focused sessions), Quick Tasks (short bursts of work), and Reading Mode. Each mode helps you structure your work and break times effectively."
        },
        {
          "question": "How flexible is the Pomodoro Timer?",
          "answer": "The timer is highly customizable. You can adjust work duration, short break length, and long break duration. Additional options include auto-start for next sessions and notification settings."
        },
        {
          "question": "What does the Focus Mode history show?",
          "answer": "Focus Mode history tracks daily focus sessions, showing the number of sessions per day, trends graph, average session duration, total focus time, and a time distribution pie chart breaking down work sessions, short breaks, and long breaks."
        },
        {
          "question": "Can I track my focus session progress?",
          "answer": "The app features a circular timer UI with play/pause, reload, and settings buttons. You can easily track and manage your focus sessions with intuitive controls."
        }
      ]
    },
    // Settings & Customization
    {
      "category": "Settings & Customization",
      "faqs": [
        {
          "question": "What customization options are available?",
          "answer": "Customization includes theme selection (System, Light, Dark), language settings, startup behavior, comprehensive notification controls, and data management options like clearing data or resetting settings."
        },
        {
          "question": "How do I provide feedback or report issues?",
          "answer": "At the bottom of the Settings section, you'll find buttons to Report a Bug, Submit Feedback, or Contact Support. These will redirect you to the appropriate support channels."
        },
        {
          "question": "What happens when I clear my data?",
          "answer": "Clearing data will reset all your usage statistics, focus session history, and custom settings. This is useful for starting fresh or troubleshooting."
        }
      ]
    },
    {
      "category": "Troubleshooting",
      "faqs": [
        {
          "question": "Data is not showing, hive is not opening error",
          "answer": "The issue is known, the temporary fix is to clear data through settings and if it doesn't work then go to Documents and delete the following files if they exist - harman_screentime_app_usage_box.hive and harman_screentime_app_usage.lock, you are also suggested to update the app to the latest version."
        },
      ]
    }
  ];

  // Rest of the class remains the same as in the original implementation
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: faqData.length + 1, // +1 for the header
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Header();
          }
          
          final categoryData = faqData[index - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  categoryData['category']!, 
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              ...categoryData['faqs']!.map((faq) => Column(
                children: [
                  FAQItem(
                    question: faq["question"]!,
                    answer: faq["answer"]!,
                  ),
                  const SizedBox(height: 5),
                ],
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}

// FAQItem and Header classes remain the same

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Expander(
      header: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(answer, style: FluentTheme.of(context).typography.body),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Help", style: FluentTheme.of(context).typography.subtitle),
      ],
    );
  }
}