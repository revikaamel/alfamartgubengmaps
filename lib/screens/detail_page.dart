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
        List.from(widget.place['reviews']);

    calculateAverageRating();
  }

  void calculateAverageRating() {

    double total = 0;

    for (var review in reviews) {

      total +=
          (review['rating'] as num)
              .toDouble();
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

  void showReviewDialog() {

    showDialog(

      context: context,

      builder: (_) {

        return StatefulBuilder(

          builder:
              (context, setDialogState) {

            return AlertDialog(

              title:
                  const Text(
                      "Tambah Ulasan"),

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
                      height: 20),

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children:
                        List.generate(5,
                            (index) {

                      return IconButton(

                        onPressed: () {

                          setDialogState(() {

                            userRating =
                                index +
                                    1.0;
                          });
                        },

                        icon: Icon(

                          Icons.star,

                          color:
                              (index + 1) <=
                                      userRating
                                  ? Colors
                                      .amber
                                  : Colors
                                      .grey,
                        ),
                      );
                    }),
                  )
                ],
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                        context);
                  },

                  child:
                      const Text("Batal"),
                ),

                ElevatedButton(

                  onPressed:
                      addReview,

                  child:
                      const Text("Kirim"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(widget.place['name']),

        actions: [

          IconButton(

            icon: Icon(

              savedPlaces.contains(widget.place)

                  ? Icons.bookmark

                  : Icons.bookmark_border,
            ),

            onPressed: () {

              setState(() {

                if (savedPlaces.contains(
                    widget.place)) {

                  savedPlaces.remove(
                      widget.place);

                } else {

                  savedPlaces.add(
                      widget.place);
                }
              });
            },
          )
        ],
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed:
            showReviewDialog,

        child:
            const Icon(Icons.add),
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            ClipRRect(

              borderRadius:
                  const BorderRadius.only(

                bottomLeft:
                    Radius.circular(20),

                bottomRight:
                    Radius.circular(20),
              ),

              child: Image.asset(

                widget.place['photo'],

                width: double.infinity,

                height: 250,

                fit: BoxFit.cover,

                errorBuilder:
                    (context,
                        error,
                        stackTrace) {

                  return Container(

                    height: 250,

                    width: double.infinity,

                    color:
                        Colors.grey[300],

                    child: const Center(

                      child: Icon(

                        Icons.image_not_supported,

                        size: 60,

                        color:
                            Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(

              padding:
                  const EdgeInsets.all(15),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    widget.place['name'],

                    style:
                        const TextStyle(

                      fontSize: 28,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Row(

                    children: [

                      const Icon(

                        Icons.star,

                        color:
                            Colors.amber,
                      ),

                      const SizedBox(
                          width: 5),

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
                      height: 10),

                  Text(
                    widget.place['address'],
                  ),

                  const SizedBox(
                      height: 20),

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      const Text(

                        "Ulasan",

                        style:
                            TextStyle(

                          fontSize: 22,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      TextButton.icon(

                        onPressed:
                            showReviewDialog,

                        icon: const Icon(
                          Icons.rate_review,
                        ),

                        label:
                            const Text(
                                "Tambah"),
                      )
                    ],
                  ),

                  const SizedBox(
                      height: 10),

                  ...reviews.map<Widget>(
                      (review) {

                    return Card(

                      elevation: 2,

                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 10,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius
                                .circular(
                                    15),
                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets
                                .all(12),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Row(

                              children:
                                  List.generate(
                                5,

                                (index) {

                                  return Icon(

                                    Icons.star,

                                    size: 18,

                                    color: index <
                                            review[
                                                'rating']
                                        ? Colors
                                            .amber
                                        : Colors
                                            .grey,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            Text(

                              review['text'],

                              style:
                                  const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(
                      height: 20),

                  SizedBox(

                    width:
                        double.infinity,

                    height: 50,

                    child:
                        ElevatedButton.icon(

                      icon: const Icon(
                          Icons.route),

                      label: const Text(
                          "Lihat Rute"),

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                RoutePage(

                              place:
                                  widget.place,

                              currentLocation:
                                  widget
                                      .currentLocation,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}