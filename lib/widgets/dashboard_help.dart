import 'package:flutter/material.dart';

class DashboardHelp extends StatelessWidget {
  const DashboardHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How to get started",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u2022',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(119, 119, 119, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: "Cabinet Grotesk",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.32,
                      ),
                      children: [
                        TextSpan(
                          text: "Capture ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "or ",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                        TextSpan(
                          text: "upload ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "any image from your phone",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u2022',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(119, 119, 119, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: "Cabinet Grotesk",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.32,
                      ),
                      children: [
                        TextSpan(
                          text: "Edit ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "your select image",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u2022',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(119, 119, 119, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: "Cabinet Grotesk",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.32,
                      ),
                      children: [
                        TextSpan(
                          text: "Give a ",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                        TextSpan(
                          text: "name ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "to the selected image and add a ",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                        TextSpan(
                          text: "description",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u2022',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(119, 119, 119, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: "Cabinet Grotesk",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.32,
                      ),
                      children: [
                        TextSpan(
                          text: "Now it's time to ",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                        TextSpan(
                          text: "mint ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "the image as an NFT",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u2022',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(119, 119, 119, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: "Cabinet Grotesk",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.32,
                      ),
                      children: [
                        TextSpan(
                          text: "All the minted image will ",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                        TextSpan(
                          text: "appear ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "here",
                          style: TextStyle(
                            color: Color.fromRGBO(119, 119, 119, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
