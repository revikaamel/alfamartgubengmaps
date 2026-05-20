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

  List reviews = [];

  double averageRating = 0;

  double userRating = 0;

  final TextEditingController
      reviewController =
      TextEditingController();

  double toDouble(dynamic value) {

    return double.tryParse(
      value.toString(),
    ) ?? 0;
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

    if (rawReviews == null) {

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
              toDouble(
                widget.place['rating'],
              ),
        };

      }).toList();
    }
  }

  void calculateAverageRating() {

    if (reviews.isEmpty) {

      averageRating =
          toDouble(
        widget.place['rating'],
      );

      return;
    }

    double total = 0;

    for (var review in reviews) {

      total +=
          toDouble(
        review['rating'],
      );
    }

    averageRating =
        total / reviews.length;
  }

  void addReview() {

    if (reviewController.text.isEmpty ||
        userRating == 0) {

      return;
    }

    setState(() {

      reviews.add({

        "text":
            reviewController.text,

        "rating":
            userRating,
      });

      widget.place['reviews'] =
          reviews;

      calculateAverageRating();

      widget.place['rating'] =
          averageRating;
    });

    reviewController.clear();

    userRating = 0;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          widget.place['name']
              .toString(),
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              widget.place['name']
                  .toString(),

              style:
                  const TextStyle(

                fontSize: 24,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "⭐ ${averageRating.toStringAsFixed(1)}",
            ),

            const SizedBox(height: 10),

            Text(
              widget.place['address']
                  .toString(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

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

              child: const Text(
                "Lihat Rute",
              ),
            ),

            const SizedBox(height: 20),

            const Text(

              "Ulasan",

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(

              child: ListView.builder(

                itemCount:
                    reviews.length,

                itemBuilder:
                    (context, index) {

                  var review =
                      reviews[index];

                  return Card(

                    child: ListTile(

                      title: Text(
                        review['text']
                            .toString(),
                      ),

                      subtitle: Text(
                        "⭐ ${review['rating']}",
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(

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
                          ),

                          DropdownButton<double>(

                            value:
                                userRating == 0
                                    ? null
                                    : userRating,

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

                                child:
                                    Text("$e"),
                              );
                            }).toList(),

                            onChanged:
                                (value) {

                              setState(() {

                                userRating =
                                    value!;
                              });
                            },
                          ),
                        ],
                      ),

                      actions: [

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

              child: const Text(
                "Tambah Ulasan",
              ),
            ),
          ],
        ),
      ),
    );
  }
}