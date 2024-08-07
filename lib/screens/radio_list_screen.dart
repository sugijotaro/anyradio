import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/radio_list_viewmodel.dart';
import 'radio_detail_screen.dart';

class RadioListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioListViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Radio List'),
        ),
        body: Consumer<RadioListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.radios.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: viewModel.radios.length,
              itemBuilder: (context, index) {
                var radio = viewModel.radios[index];
                return ListTile(
                  title: Text(radio.title),
                  subtitle: Text(radio.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RadioDetailScreen(radioId: radio.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
