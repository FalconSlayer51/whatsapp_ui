import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/status/controller/status_controller.dart';
import 'package:whatsapp_ui/features/status/screens/status_screen.dart';
import 'package:whatsapp_ui/models/status_model.dart';

class StatusContactsScreen extends ConsumerWidget {
  const StatusContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Status>>(
      future: ref.read(statusControllerProvider).getStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'no Stauses',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                  ),
                ),
              );
            }
            var statusData = snapshot.data![index];
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      StatusScreen.routeName,
                      arguments: statusData,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ListTile(
                      title: Text(
                        statusData.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          statusData.profilePic,
                        ),
                        radius: 30,
                      ),
                    ),
                  ),
                ),
                const Divider(color: dividerColor, indent: 85),
              ],
            );
          },
        );
      },
    );
  }
}
