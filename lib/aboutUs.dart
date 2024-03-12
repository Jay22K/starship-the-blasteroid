import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AboutUs extends StatelessWidget {
  static const routeName = 'about-us';
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _buildPortraitLayout(context)
                  : _buildLandscapeLayout(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const RiveAnimation.asset(
            'assets/animation/rocket_demo.riv',
            // fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About us",
                style: TextStyle(color: Colors.yellow),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About Us',
                      style: TextStyle(
                        color: Colors.amber,
                        fontFamily: 'OtraMasStf',
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Jayesh Baviskar ',
                      style: TextStyle(
                        color: Colors.amber,
                        fontFamily: 'Poppins',
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'Made with ❤️',
                      style: TextStyle(
                        color: Colors.amber,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Image.network(
                            'https://thumbs.dreamstime.com/b/logo-icon-vector-logos-icons-set-social-media-flat-banner-vectors-svg-eps-jpg-jpeg-paper-texture-glossy-emblem-wallpaper-210442689.jpg',
                          ),
                          onPressed: () {
                            // window.open('https://example.com/url1', '_blank');
                          },
                        ),
                        IconButton(
                          icon: Image.network(
                            'https://cdn-icons-png.flaticon.com/256/174/174857.png',
                          ),
                          onPressed: () {
                            // window.open('https://example.com/url2', '_blank');
                          },
                        ),
                        IconButton(
                          icon: Image.network(
                            'https://cdn0.iconfinder.com/data/icons/free-social-media-set/24/github-512.png',
                          ),
                          onPressed: () {
                            // window.open('https://example.com/url3', '_blank');
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.5,
              child: const RiveAnimation.asset(
                'assets/animation/rocket_demo.riv',
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.amber), // You can use your own back button icon
            onPressed: () {
              // Add code t o handle back button press (e.g., navigate back)
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
