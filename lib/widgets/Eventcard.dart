import 'package:flutter/material.dart';
class EventCard extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String image4x3;


  const EventCard({
    Key? key,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.image4x3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do evento
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.asset(
              image4x3,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do evento
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // Descrição do evento
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                // Localização e datas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      "${startDate.toLocal().toString().split(' ')[0]} - ${endDate.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  }