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

      body: SingleChildScrollView(

        child: Column(

          children: [

            Image.asset(

              'assets/images/${widget.place['photo']}.jpg',

              width: double.infinity,

              height: 250,

              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}