import 'package:bulletin/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
class NewsDetails extends StatefulWidget {
  Article article;
  NewsDetails(this.article, {Key? key}) : super(key: key);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {

_launchUrl () async {
  final url = widget.article.url;
  if (await canLaunch(url))
    await launch(url);
  else
    throw "Could not launch";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          color: Colors.grey.shade300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (widget.article.urlToImage == null )
              ? Image(image: AssetImage('assets/images/bulletin-logo.png'),)
              : Image(image: NetworkImage(widget.article.urlToImage,)
              ),
              widget.article.description != null
              ? Text(
                widget.article.description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              )
                  : const Text('Tap on the button to read the full article.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,),
              SizedBox(),

              GestureDetector(
                onTap: _launchUrl,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(color: Colors.grey),
                    ),
                    const Text(
                        'Read Complete Article',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              ),
            ],
          )
        ),
      ),
    );
  }
}
