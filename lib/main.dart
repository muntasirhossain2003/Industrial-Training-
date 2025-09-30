import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color cardHeaderFooterColor = Color(0xFF1B4332);
  Color cardContentColor = Colors.white;
  final Random random = Random();
  String currentFont = 'Roboto';

  List<String> availableFonts = [
    'Roboto',
    'Lato',
    'Oswald',
    'Montserrat',
    'Raleway',
  ];

  Color generateRandomColor() {
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  bool areColorsSimilar(Color color1, Color color2) {
    int redDiff = (color1.red - color2.red).abs();
    int greenDiff = (color1.green - color2.green).abs();
    int blueDiff = (color1.blue - color2.blue).abs();

    return (redDiff + greenDiff + blueDiff) < 100;
  }

  Color getInverseColor(Color color) {
    return Color.fromARGB(
      255,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

  void changeColors() {
    setState(() {
      Color newHeaderFooterColor;
      Color newContentColor;

      newHeaderFooterColor = generateRandomColor();

      do {
        newContentColor = generateRandomColor();
      } while (areColorsSimilar(newHeaderFooterColor, newContentColor));

      cardHeaderFooterColor = newHeaderFooterColor;
      cardContentColor = newContentColor;
    });
  }

  void changeFontStyle() {
    setState(() {
      String newFont;
      do {
        newFont = availableFonts[random.nextInt(availableFonts.length)];
      } while (newFont == currentFont);
      currentFont = newFont;
    });
  }

  TextStyle getTextStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.getFont(
      currentFont,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate inverse colors for text
    // For initial state, use white for header/footer text
    Color headerFooterTextColor = cardHeaderFooterColor == Color(0xFF1B4332)
        ? Colors.white
        : getInverseColor(cardHeaderFooterColor);
    Color contentTextColor = cardContentColor == Colors.white
        ? Colors.black
        : getInverseColor(cardContentColor);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('Student ID Card'),
          backgroundColor: Color.fromARGB(255, 253, 255, 254),
          actions: [
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: changeColors,
              tooltip: 'Change Card Colors',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dark Header with Logo and University Name
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: cardHeaderFooterColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/iut-logo.jpeg',
                              height: 65,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontSize: 15,
                                color: headerFooterTextColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Area
                      Container(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
                        color: cardContentColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Image
                            Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: contentTextColor,
                                    width: 3,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/profile image.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Student ID
                            Row(
                              children: [
                                Icon(
                                  Icons.vpn_key,
                                  size: 18,
                                  color: contentTextColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Student ID',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: contentTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: cardHeaderFooterColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: headerFooterTextColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '210041265',
                                    style: getTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: headerFooterTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Student Name
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: contentTextColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Student Name',
                                      style: getTextStyle(
                                        fontSize: 13,
                                        color: contentTextColor.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Muntasir Hossain',
                                      style: getTextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: contentTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 14),

                            // Program
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.school,
                                    size: 20,
                                    color: contentTextColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Program BSc in CSE',
                                  style: getTextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: contentTextColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),

                            // Department
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.business,
                                    size: 20,
                                    color: contentTextColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Department CSE',
                                  style: getTextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: contentTextColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),

                            // Location
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 20,
                                    color: contentTextColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Bangladesh',
                                  style: getTextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: contentTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: cardHeaderFooterColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'A subsidiary organ of OIC',
                            style: getTextStyle(
                              fontSize: 12,
                              color: headerFooterTextColor.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: changeFontStyle,
              backgroundColor: Colors.blue[800],
              heroTag: 'fontButton',
              child: Icon(Icons.font_download, color: Colors.white),
              tooltip: 'Change Font Style',
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: changeColors,
              backgroundColor: Color(0xFF1B4332),
              heroTag: 'colorButton',
              child: Icon(Icons.color_lens, color: Colors.white),
              tooltip: 'Change Colors',
            ),
          ],
        ),
      ),
    );
  }
}
