import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<Map<String, dynamic>> faqData = [
      // General Questions
      {
        "category": l10n.faqCategoryGeneral,
        "faqs": [
          {
            "question": l10n.faqGeneralQ1,
            "answer": l10n.faqGeneralA1
          },
          {
            "question": l10n.faqGeneralQ2,
            "answer": l10n.faqGeneralA2
          },
          {
            "question": l10n.faqGeneralQ3,
            "answer": l10n.faqGeneralA3
          },
          {
            "question": l10n.faqGeneralQ4,
            "answer": l10n.faqGeneralA4
          },
          {
            "question": l10n.faqGeneralQ5,
            "answer": l10n.faqGeneralA5
          },
          {
            "question": l10n.faqGeneralQ6,
            "answer": l10n.faqGeneralA6
          },
          {
            "question": l10n.faqGeneralQ7,
            "answer": l10n.faqGeneralA7
          }
        ]
      },
      // Applications Management
      {
        "category": l10n.faqCategoryApplications,
        "faqs": [
          {
            "question": l10n.faqAppsQ1,
            "answer": l10n.faqAppsA1
          },
          {
            "question": l10n.faqAppsQ2,
            "answer": l10n.faqAppsA2
          },
          {
            "question": l10n.faqAppsQ3,
            "answer": l10n.faqAppsA3
          },
          {
            "question": l10n.faqAppsQ4,
            "answer": l10n.faqAppsA4
          }
        ]
      },
      // Usage Analytics & Reports
      {
        "category": l10n.faqCategoryReports,
        "faqs": [
          {
            "question": l10n.faqReportsQ1,
            "answer": l10n.faqReportsA1
          },
          {
            "question": l10n.faqReportsQ2,
            "answer": l10n.faqReportsA2
          },
          {
            "question": l10n.faqReportsQ3,
            "answer": l10n.faqReportsA3
          },
          {
            "question": l10n.faqReportsQ4,
            "answer": l10n.faqReportsA4
          }
        ]
      },
      // Alerts & Limits
      {
        "category": l10n.faqCategoryAlerts,
        "faqs": [
          {
            "question": l10n.faqAlertsQ1,
            "answer": l10n.faqAlertsA1
          },
          {
            "question": l10n.faqAlertsQ2,
            "answer": l10n.faqAlertsA2
          },
          {
            "question": l10n.faqAlertsQ3,
            "answer": l10n.faqAlertsA3
          }
        ]
      },
      // Focus Mode & Pomodoro Timer
      {
        "category": l10n.faqCategoryFocusMode,
        "faqs": [
          {
            "question": l10n.faqFocusQ1,
            "answer": l10n.faqFocusA1
          },
          {
            "question": l10n.faqFocusQ2,
            "answer": l10n.faqFocusA2
          },
          {
            "question": l10n.faqFocusQ3,
            "answer": l10n.faqFocusA3
          },
          {
            "question": l10n.faqFocusQ4,
            "answer": l10n.faqFocusA4
          }
        ]
      },
      // Settings & Customization
      {
        "category": l10n.faqCategorySettings,
        "faqs": [
          {
            "question": l10n.faqSettingsQ1,
            "answer": l10n.faqSettingsA1
          },
          {
            "question": l10n.faqSettingsQ2,
            "answer": l10n.faqSettingsA2
          },
          {
            "question": l10n.faqSettingsQ3,
            "answer": l10n.faqSettingsA3
          },
          {
            "question": l10n.faqSettingsQ4,
            "answer": l10n.faqSettingsA4
          }
        ]
      },
      // Troubleshooting
      {
        "category": l10n.faqCategoryTroubleshooting,
        "faqs": [
          {
            "question": l10n.faqTroubleQ1,
            "answer": l10n.faqTroubleA1
          },
          {
            "question": l10n.faqTroubleQ2,
            "answer": l10n.faqTroubleA2
          },
        ]
      }
    ];

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
                  categoryData['category'] as String, 
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              ...(categoryData['faqs'] as List<Map<String, String>>).map((faq) => Column(
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
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.helpTitle, style: FluentTheme.of(context).typography.subtitle),
      ],
    );
  }
}