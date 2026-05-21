import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
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

  List reviews = [];

  late double averageRating;

  double userRating = 0;

  final TextEditingController
      reviewController =
      TextEditingController();

  double toDouble(dynamic value) {
    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  @override
  void initState() {
    super.initState();

    loadReviews();

    calculateAverageRating();
  }

  void loadReviews() {
    var rawReviews =
        widget.place['reviews'];

    if (rawReviews == null ||
        rawReviews.toString().isEmpty) {

      reviews = [];

      return;
    }

    if (rawReviews is List) {

      reviews = List.from(rawReviews);

    } else {

      List<String> reviewTexts =
          rawReviews
              .toString()
              .split(";");

      reviews =
          reviewTexts.map((text) {

        return {
          "text": text.trim(),
          "rating":
              widget.place['rating'],
        };

      }).toList();
    }
  }

  void calculateAverageRating() {

    double originalRating =
        toDouble(
      widget.place['rating'],
    );

    if (reviews.isEmpty) {

      averageRating =
          originalRating;

      return;
    }

    double total = originalRating;

    int count = 1;

    for (var review in reviews) {

      total += toDouble(
        review['rating'],
      );

      count++;
    }

    averageRating =
        total / count;
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

      widget.place['reviews'] =
          reviews;

      calculateAverageRating();
    });

    reviewController.clear();

    userRating = 0;

    Navigator.pop(context);
  }

  void editReview(int index) {

    reviewController.text =
        reviews[index]['text'];

    userRating = toDouble(
      reviews[index]['rating'],
    );

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "Edit Ulasan",
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
                      "Edit ulasan",
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              DropdownButton<double>(

                value: userRating,

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

              onPressed: () {

                setState(() {

                  reviews[index] = {

                    "text":
                        reviewController
                            .text,

                    "rating":
                        userRating,
                  };

                  widget.place['reviews'] =
                      reviews;

                  calculateAverageRating();
                });

                reviewController
                    .clear();

                Navigator.pop(
                    context);
              },

              child: const Text(
                "Simpan",
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteReview(int index) {

    setState(() {

      reviews.removeAt(index);

      widget.place['reviews'] =
          reviews;

      calculateAverageRating();
    });
  }

  String getPhotoPath(String photo) {

    if (photo.isEmpty) {

      return "assets/images/default.png";
    }

    if (photo.contains(
        "assets/images/")) {

      return photo;
    }

    return "assets/images/$photo";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
            Text(
          widget.place['name']
              .toString(),
        ),

        actions: [

          IconButton(

            icon: Icon(

              isSaved()

                  ? Icons.bookmark

                  : Icons
                      .bookmark_border,
            ),

            onPressed:
                toggleSave,
          ),
        ],
      ),

      body:
          SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Image.asset(

              getPhotoPath(
                widget.place['photo']
                    .toString(),
              ),

              width:
                  double.infinity,

              height: 250,

              fit: BoxFit.cover,

              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {

                return Container(

                  width:
                      double.infinity,

                  height: 250,

                  color:
                      Colors.grey[300],

                  child:
                      const Icon(

                    Icons.image,

                    size: 80,
                  ),
                );
              },
            ),

            Padding(

              padding:
                  const EdgeInsets
                      .all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    widget.place['name']
                        .toString(),

                    style:
                        const TextStyle(

                      fontSize: 24,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(

                    children: [

                      const Icon(

                        Icons.star,

                        color: Colors
                            .orange,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(

                        averageRating
                            .toStringAsFixed(
                                1),

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
                    widget.place[
                                'address']
                            ?.toString() ??
                        "Alamat tidak tersedia",
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    width:
                        double.infinity,

                    height: 50,

                    child:
                        ElevatedButton
                            .icon(

                      icon: const Icon(
                        Icons.route,
                      ),

                      label:
                          const Text(
                        "Lihat Rute",
                      ),

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                RoutePage(

                              place:
                                  widget
                                      .place,

                              currentLocation:
                                  widget
                                      .currentLocation,
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

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight
                              .bold,
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

                    ...reviews
                        .asMap()
                        .entries
                        .map((entry) {

                      int index =
                          entry.key;

                      var review =
                          entry.value;

                      return Card(

                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 10,
                        ),

                        child:
                            ListTile(

                          leading:
                              const Icon(
                            Icons.person,
                          ),

                          title: Text(
                            review['text']
                                .toString(),
                          ),

                          subtitle: Text(
                            "⭐ ${review['rating']}",
                          ),

                          trailing:
                              Row(

                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons.edit,
                                  color:
                                      Colors.blue,
                                ),

                                onPressed:
                                    () {

                                  editReview(
                                      index);
                                },
                              ),

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),

                                onPressed:
                                    () {

                                  deleteReview(
                                      index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    width:
                        double.infinity,

                    height: 50,

                    child:
                        ElevatedButton
                            .icon(

                      icon: const Icon(
                        Icons.rate_review,
                      ),

                      label:
                          const Text(
                        "Tambah Ulasan",
                      ),

                      onPressed: () {

                        reviewController
                            .clear();

                        userRating = 0;

                        showDialog(

                          context:
                              context,

                          builder: (_) {

                            return AlertDialog(

                              title:
                                  const Text(
                                "Tambah Ulasan",
                              ),

                              content:
                                  Column(

                                mainAxisSize:
                                    MainAxisSize
                                        .min,

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
                                    height:
                                        15,
                                  ),

                                  DropdownButton<
                                      double>(

                                    value:
                                        userRating ==
                                                0
                                            ? null
                                            : userRating,

                                    hint:
                                        const Text(
                                      "Pilih Rating",
                                    ),

                                    isExpanded:
                                        true,

                                    items: [

                                      1,
                                      2,
                                      3,
                                      4,
                                      5

                                    ].map((e) {

                                      return DropdownMenuItem(

                                        value: e
                                            .toDouble(),

                                        child:
                                            Text(
                                          "$e ⭐",
                                        ),
                                      );
                                    }).toList(),

                                    onChanged:
                                        (
                                      value,
                                    ) {

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

                                  onPressed:
                                      () {

                                    Navigator.pop(
                                        context);
                                  },

                                  child:
                                      const Text(
                                    "Batal",
                                  ),
                                ),

                                ElevatedButton(

                                  onPressed:
                                      addReview,

                                  child:
                                      const Text(
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