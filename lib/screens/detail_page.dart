import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/places.dart';
import 'route_page.dart';

class DetailPage extends StatefulWidget {

  final Map place;
  final LatLng currentLocation;

  const DetailPage({
    super.key,
    required this.place,
    required this.currentLocation,
  });

  @override
  State<DetailPage> createState() =>
      _DetailPageState();
}

class _DetailPageState
    extends State<DetailPage> {

  late List reviews;

  late double averageRating;

  double userRating = 0;

  final TextEditingController
      reviewController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    reviews =
        List.from(
      widget.place['reviews'] ?? [],
    );

    calculateAverageRating();
  }

  void calculateAverageRating() {

    if (reviews.isEmpty) {

      averageRating =
          (widget.place['rating'] as num)
              .toDouble();

      return;
    }

    double total = 0;

    for (var review in reviews) {

      total +=
          (review['rating'] as num)
              .toDouble();
    }

    averageRating =
        total / reviews.length;
  }

  bool isSaved() {

    return savedPlaces.any(

      (item) =>

          item['name'] ==
          widget.place['name'],
    );
  }

  void toggleSave() {

    setState(() {

      if (isSaved()) {

        savedPlaces.removeWhere(

          (item) =>

              item['name'] ==
              widget.place['name'],
        );

      } else {

        savedPlaces.add(
          widget.place,
        );
      }

      print(savedPlaces);
    });
  }

  void addReview() {

    if (reviewController.text.isEmpty ||
        userRating == 0) {

      return;
    }

    setState(() {

      reviews.add({

        'text':
            reviewController.text,

        'rating':
            userRating,
      });

      calculateAverageRating();
    });

    reviewController.clear();

    userRating = 0;

    Navigator.pop(context);
  }

  String getPhotoPath(String photo) {

    if (photo.contains(".")) {

      return "assets/images/$photo";
    }

    List extensions = [

      ".jpg",
      ".jpeg",
      ".png",
      ".webp"
    ];

    for (var ext in extensions) {

      return "assets/images/$photo$ext";
    }

    return "assets/images/default.png";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
            Text(widget.place['name']),

        actions: [

          IconButton(

            icon: Icon(

              isSaved()

                  ? Icons.bookmark

                  : Icons.bookmark_border,
            ),

            onPressed: toggleSave,
          ),
        ],
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Image.asset(

              getPhotoPath(
                widget.place['photo'],
              ),

              width: double.infinity,

              height: 250,

              fit: BoxFit.cover,

              errorBuilder:
                  (context,
                      error,
                      stackTrace) {

                return Container(

                  width: double.infinity,

                  height: 250,

                  color: Colors.grey[300],

                  child: const Icon(

                    Icons.image,

                    size: 80,
                  ),
                );
              },
            ),

            Padding(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    widget.place['name'],

                    style:
                        const TextStyle(

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(

                    children: [

                      const Icon(

                        Icons.star,

                        color: Colors.orange,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(

                        averageRating
                            .toStringAsFixed(1),

                        style:
                            const TextStyle(

                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    widget.place['address'] ??
                        "Alamat tidak tersedia",

                    style:
                        const TextStyle(

                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    width: double.infinity,

                    height: 50,

                    child:
                        ElevatedButton.icon(

                      icon: const Icon(
                        Icons.route,
                      ),

                      label: const Text(
                        "Lihat Rute",
                      ),

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                RoutePage(

                              place:
                                  widget.place,

                              currentLocation:
                                  widget.currentLocation,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  const Text(

                    "Ulasan",

                    style:
                        TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if (reviews.isEmpty)

                    const Text(
                      "Belum ada ulasan",
                    )

                  else

                    ...reviews.map((review) {

                      return Card(

                        margin:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),

                        child: ListTile(

                          leading: const Icon(
                            Icons.person,
                          ),

                          title: Text(
                            review['text'],
                          ),

                          subtitle: Text(
                            "⭐ ${review['rating']}",
                          ),
                        ),
                      );
                    }),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    width: double.infinity,

                    height: 50,

                    child:
                        ElevatedButton.icon(

                      icon: const Icon(
                        Icons.rate_review,
                      ),

                      label: const Text(
                        "Tambah Ulasan",
                      ),

                      onPressed: () {

                        showDialog(

                          context: context,

                          builder: (_) {

                            return AlertDialog(

                              title: const Text(
                                "Tambah Ulasan",
                              ),

                              content: Column(

                                mainAxisSize:
                                    MainAxisSize.min,

                                children: [

                                  TextField(

                                    controller:
                                        reviewController,

                                    decoration:
                                        const InputDecoration(

                                      hintText:
                                          "Tulis ulasan",
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 15,
                                  ),

                                  DropdownButton<double>(

                                    value:
                                        userRating == 0

                                            ? null

                                            : userRating,

                                    hint: const Text(
                                      "Pilih Rating",
                                    ),

                                    isExpanded: true,

                                    items: [

                                      1,
                                      2,
                                      3,
                                      4,
                                      5

                                    ].map((e) {

                                      return DropdownMenuItem(

                                        value:
                                            e.toDouble(),

                                        child: Text(
                                          "$e ⭐",
                                        ),
                                      );
                                    }).toList(),

                                    onChanged: (value) {

                                      setState(() {

                                        userRating =
                                            value!;
                                      });
                                    },
                                  ),
                                ],
                              ),

                              actions: [

                                TextButton(

                                  onPressed: () {

                                    Navigator.pop(
                                        context);
                                  },

                                  child: const Text(
                                    "Batal",
                                  ),
                                ),

                                ElevatedButton(

                                  onPressed:
                                      addReview,

                                  child: const Text(
                                    "Simpan",
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}