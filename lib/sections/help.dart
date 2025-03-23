import 'package:fluent_ui/fluent_ui.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  final List<Map<String, String>> faqData = const [
    {
      "question": "How does Productive ScreenTime work?",
      "answer": "Productive ScreenTime tracks your application usage and provides insights into your productivity, focus mode, and app usage reports."
    },
    {
      "question": "Can I customize alerts and limits?",
      "answer": "Yes, you can set custom time limits for applications and receive alerts when limits are reached."
    },
    {
      "question": "Does this app run in the background?",
      "answer": "Yes, it runs in the background and minimizes to the system tray when closed."
    },
    {
      "question": "How do I enable dark mode?",
      "answer": "Go to Settings and switch between Light and Dark mode based on your preference."
    },
    {
      "question": "Where can I report issues or request features?",
      "answer": "You can report issues or suggest new features on our GitHub repository or contact support through the Help section."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Header(),
          const SizedBox(height: 20),
          const Text("General", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          ...faqData.map((faq) => FAQItem(
                question: faq["question"]!,
                answer: faq["answer"]!,
              ))
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({Key? key, required this.question, required this.answer}) : super(key: key);

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
        // Row(
        //   children: [
        //     Button(
        //       style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 12))),
        //       child: const Row(
        //         children: [
        //           Icon(FluentIcons.red_eye, size: 20),
        //           SizedBox(width: 10),
        //           Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
        //         ],
        //       ),
        //       onPressed: () => debugPrint('pressed button'),
        //     ),
        //     const SizedBox(width: 25),
        //     Button(
        //       style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 14))),
        //       child: const Row(
        //         children: [
        //           Icon(FluentIcons.app_icon_default_list, size: 18),
        //           SizedBox(width: 10),
        //           Text('Report Bug', style: TextStyle(fontWeight: FontWeight.w600)),
        //         ],
        //       ),
        //       onPressed: () => debugPrint('pressed button'),
        //     ),
        //   ],
        // )
      ],
    );
  }
}
