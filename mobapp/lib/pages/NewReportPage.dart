import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/Reports/report_bloc.dart';

class NewReportPage extends StatefulWidget {
  const NewReportPage({super.key});

  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  List<File> images = [];
  final ImagePicker imagePicker = ImagePicker();
  String? selectedSeverity; // 'media', 'grave', 'muy_grave'

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
      }
    });
  }

  Future<void> _openCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
      }
    });
  }

  void _submitForm(ReportBloc reportBloc) {
    if (_formKey.currentState!.validate() && selectedSeverity != null) {
      reportBloc.add(
        CreateReport(
          severity: selectedSeverity!,
          description: _descriptionController.text,
          location: _locationController.text,
          imagePaths: images.map((file) => file.path).toList(),
          prevState: reportBloc.state as ReportsLoaded,
        ),
      );
    } else if (selectedSeverity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona la gravedad del bache')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reporte creado exitosamente')),
          );
          Navigator.of(context).pop();
        } else if (state is CreateReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    title: const Text('Nuevo reporte', style: TextStyle(fontSize: 20)),
                    leading: const Icon(Icons.arrow_back_ios, size: 20),
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Llena los siguientes detalles y sube fotos para crear un reporte.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Text('¿Como consideras la gravedad del bache?',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size(50, 60),
                            side: BorderSide(
                              color: selectedSeverity == 'media' ? Colors.yellow.shade700 : Colors.yellow,
                              width: selectedSeverity == 'media' ? 3.0 : 2.0,
                            ),
                            backgroundColor: selectedSeverity == 'media' ? Colors.yellow.withOpacity(0.1) : null,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedSeverity = 'media';
                            });
                          },
                          child: Text('😐', style: TextStyle(
                            fontSize: 16,
                            color: selectedSeverity == 'media' ? Colors.yellow.shade800 : null,
                          )),
                        ),
                        const Text('Media', style: TextStyle(fontSize: 12)),
                      ]),
                      Column(children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size(50, 60),
                            side: BorderSide(
                              color: selectedSeverity == 'grave' ? Colors.orange.shade700 : Colors.orange,
                              width: selectedSeverity == 'grave' ? 3.0 : 2.0,
                            ),
                            backgroundColor: selectedSeverity == 'grave' ? Colors.orange.withOpacity(0.1) : null,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedSeverity = 'grave';
                            });
                          },
                          child: Text('😫', style: TextStyle(
                            fontSize: 16,
                            color: selectedSeverity == 'grave' ? Colors.orange.shade800 : null,
                          )),
                        ),
                        const Text('Grave', style: TextStyle(fontSize: 12)),
                      ]),
                      Column(children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size(50, 60),
                            side: BorderSide(
                              color: selectedSeverity == 'muy_grave' ? Colors.red.shade700 : Colors.red,
                              width: selectedSeverity == 'muy_grave' ? 3.0 : 2.0,
                            ),
                            backgroundColor: selectedSeverity == 'muy_grave' ? Colors.red.withOpacity(0.1) : null,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedSeverity = 'muy_grave';
                            });
                          },
                          child: Text('😠', style: TextStyle(
                            fontSize: 16,
                            color: selectedSeverity == 'muy_grave' ? Colors.red.shade800 : null,
                          )),
                        ),
                        const Text('Muy grave', style: TextStyle(fontSize: 12)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Ubicación', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                              hintText: 'Escribe la ubicación o selecciona en el mapa',
                              border: OutlineInputBorder()),
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una ubicación';
                            }
                            return null;
                          },
                        )),
                    const SizedBox(width: 10),
                    IconButton(
                        style: IconButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey[500]!,
                            width: 2.0,
                          ),
                        ),
                        onPressed: () {

                        },
                        icon: const Icon(Icons.location_on_outlined, size: 30))
                  ]),
                  const SizedBox(height: 20),
                  const Text('Descripción', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        hintText: 'Describe el problema',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10)),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Fotografías', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  // make a container for the images
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey, style: BorderStyle.values[1]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: images.isEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // add a button to add an image and a camera icon
                              IconButton(
                                icon:
                                    const Icon(Icons.photo_library_outlined, size: 30),
                                onPressed: _openGallery,
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt, size: 30),
                                onPressed: _openCamera,
                              ),
                            ],
                          )
                        : GridView.builder(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: images.length + 1,
                            itemBuilder: (context, index) {
                              if (index == images.length) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.photo_library_outlined,
                                                size: 30),
                                            onPressed: _openGallery,
                                          ),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.camera_alt, size: 30),
                                            onPressed: _openCamera,
                                          ),
                                        ])
                                  ],
                                );
                              }
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    images.removeAt(index);
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Image.file(images[index], fit: BoxFit.cover),
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: state is ReportCreating
                        ? null
                        : () {
                        //print(state);
                        _submitForm(context.read<ReportBloc>());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                    ),
                    child: state is ReportCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar reporte',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
