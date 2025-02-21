import 'package:fluent_ui/fluent_ui.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Map<String, String> version = {"version":"1.0.0","type":"Stable Build"};
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 30),
              const GeneralSection(),
              const SizedBox(height: 30),
              const NotificationSection(),
              const SizedBox(height: 30),
              const DataSection(),
              const SizedBox(height: 30),
              AboutSection(version: version),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 14,right: 14))),
                  child:const Row(
                    children: [
                      Icon(FluentIcons.canned_chat,size: 18,),
                      SizedBox(width: 10,),
                      Text('Contact',style: TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                  onPressed: () => debugPrint('pressed button'),
                ),
                  const SizedBox(width: 25,),
                  Button(
                    style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 14,right: 14))),
                    child:const Row(
                      children: [
                        Icon(FluentIcons.bug,size: 18,),
                        SizedBox(width: 10,),
                        Text('Report Bug',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    onPressed: () => debugPrint('pressed button'),
                  ),
                ],
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}


class GeneralSection extends StatelessWidget {
  const GeneralSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("General",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 180,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
          ),
          child:const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(title: "Theme",description: "Color theme of the application",),
              OptionSetting(title: "Language",description: "Language of the application",),
              OptionSetting(title: "Startup Behaviour",description: "Launch at OS startup",optionType: "switch"),
            ],
          ),
        )
      ],
    );
  }
}
class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Notifications",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 240,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
          ),
          child:const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(title: "Notifications",description: "All notifications of the application",optionType: "switch"),
              OptionSetting(title: "Focus Mode",description: "All Notifications for focus mode",optionType: "switch"),
              OptionSetting(title: "Screen Time",description: "All Notifications for screen time restriction",optionType: "switch"),
              OptionSetting(title: "Application Screen Time",description: "All Notifications for application screen time restriction",optionType: "switch"),
            ],
          ),
        )
      ],
    );
  }
}

class DataSection extends StatelessWidget {
  const DataSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Data",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 120,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
          ),
          child:const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(title: "Clear Data",description: "Clear all the history and other related data",optionType: "button",),
              OptionSetting(title: "Reset Settings",description: "Reset all the settings",optionType: "button"),
            ],
          ),
        )
      ],
    );
  }
}
class AboutSection extends StatelessWidget {
  final Map<String, String> version;
  const AboutSection({
    super.key,
    required this.version

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Version",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 75,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Version",style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("Current version of the app",style: TextStyle(fontSize: 12),),
                  ]),
                  Column(
                    children: [
                      Text("${version["version"]}",style: TextStyle(fontWeight: FontWeight.bold),),
                      Text("${version["type"]}",style: TextStyle(fontSize: 12),),
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class OptionSetting extends StatelessWidget {
  final String title;
  final String description;
  final String optionType;

  const OptionSetting({
    super.key,
    required this.title,
    required this.description,
    this.optionType = "options", // Default to "options"
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description, style: const TextStyle(fontSize: 12)),
          ],
        ),
        _buildOptionWidget(), // Function to return the correct widget
      ],
    );
  }

  Widget _buildOptionWidget() {
    switch (optionType) {
      case "switch":
        return ToggleSwitch(
          checked: true, // You can pass a dynamic value
          onChanged: (value) {
            // Handle switch toggle
          },
        );
      case "button":
        return FilledButton(
          style:const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xffDC143C)),foregroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 171, 134, 142)),padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30,vertical: 10))),
          onPressed: () {
            // Handle button press
          },
          child: const Text("Click Me", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        );
      case "options":
      default:
        return DropDownButton(
          title: const Text('Email'),
          items: [
            MenuFlyoutItem(text: const Text('Send'), onPressed: () {}),
          ],
        );
    }
  }
}



class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Settings",style: FluentTheme.of(context).typography.subtitle,),
      ],
    );
  }
}