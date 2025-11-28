import 'package:DIAPotholeReporter1/blocs/Reports/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './NewReportPage.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ListTile(
              title: Text('Reportes', style: TextStyle(fontSize: 20)),
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero),
          const SizedBox(height: 10),
          BlocBuilder<ReportBloc, ReportState>(builder: (context, state) {
            switch (state.runtimeType) {
              case ReportsLoaded:
                if ((state as ReportsLoaded).reports.isEmpty) {
                  // add a warning icon
                  return const NewReportButton(empty: true,);
                }
                return Center(
                  child: Column(
                    children: [
                      ListView.builder(
                      shrinkWrap: true,
                      itemCount: (state).reports.length,
                      itemBuilder: (context, index) {
                      return Card(
                      child: ListTile(
                      title: Text((state)
                          .reports[index]
                          .createdAt
                          .toString())));
                      }),
                      const NewReportButton(empty: false)
                  ]),
                );

              case ReportsError:
                return const Center(child: Text('Error cargando reportes'));
              case ReportsLoading:
                return const SizedBox(
                    height: 100, child: Center(child: CircularProgressIndicator( color: Colors.blueGrey)
                ));
              default:
                print(state.runtimeType);
                return const Text('Error cargando reportes');
            }
          })
        ]));
  }
}

class NewReportButton extends StatelessWidget {
  const NewReportButton({
    super.key,
    this.empty = true,
  });

  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          empty ? Column(children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.grey[800],
              size: 50,
            ),
            const Text(
              'No hay reportes',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5,),
            const Text(
              'Ayuda a la comunidad reportando un bache',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ]) : Container(),
          const SizedBox(height: 15,),
          // add a button to go to the report page
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[800],
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NewReportPage()
                  )
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.grey[800],
                size: 20,
              ),
              const SizedBox(width: 5),
              const Text(
                'Reportar',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],)
          ),
        ]));
  }
}

