import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/news.dart';
import 'adminhomepage.dart';
import 'adminprofilepage.dart';
import 'package:resicareapp/loginpage.dart';

class NewsManagerPage extends StatefulWidget {
  final int userId;

  NewsManagerPage({required this.userId});

  @override
  _NewsManagerPageState createState() => _NewsManagerPageState();
}

class _NewsManagerPageState extends State<NewsManagerPage> {
  late List<News> _newsList = [];
  TextEditingController _searchController = TextEditingController();
  List<News> _filteredNews = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<News> newsList = await dbHelper.getNews();
    setState(() {
      _newsList = newsList;
      _filteredNews = newsList;
    });
  }

  void _searchNews(String keyword) {
    setState(() {
      _filteredNews = _newsList.where((news) {
        return news.newsText.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  void _showAddNewsForm(BuildContext context) {
    TextEditingController newsTextController = TextEditingController();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add News'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: newsTextController,
                    decoration: InputDecoration(labelText: 'News Text'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'News text is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addNews(newsTextController.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  void _addNews(String newsText) async {
    News newNews = News(
      newsText: newsText,
      ownerId: widget.userId,
    );
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.insertNews(newNews);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('News Added Successfully'),
      ),
    );
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://static.vecteezy.com/system/resources/previews/021/620/518/original/wall-concrete-with-3d-open-window-against-blue-sky-and-clouds-exterior-rooftop-white-cement-building-ant-view-minimal-modern-architecture-with-summer-sky-backdrop-background-for-spring-summer-vector.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 15.0,
            child: Text(
              'News Manager',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 59, 59, 61),
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            top: 120.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 450.0,
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search News',
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      ),
                      onChanged: _searchNews,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildNewsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple[200]!),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            'Total News: ${_newsList.length}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'Show Total News',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.pink[200]!),
                  ),
                  onPressed: () {
                    _showAddNewsForm(context);
                  },
                  child: Text(
                    'Add News',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[200],
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        notchMargin: 5,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProfilePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.person),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHomePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.home),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(Icons.logout),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    List<News> newsToShow = _filteredNews.isNotEmpty ? _filteredNews : _newsList;

    if (newsToShow.isEmpty) {
      return Center(
        child: Text(
          'No News Available',
          style: GoogleFonts.poppins(),
        ),
      );
    }

    // Reverse the list to display the latest news first
    newsToShow = newsToShow.reversed.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: newsToShow.length,
      itemBuilder: (context, index) {
        News news = newsToShow[index];
        return ListTile(
          title: Text(news.newsText, style: GoogleFonts.poppins()),
          subtitle: Text('${news.newsDate} ${news.newsTime}', style: GoogleFonts.poppins()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editNews(context, news);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteNews(context, news.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _editNews(BuildContext context, News news) {
    TextEditingController _editNewsController =
    TextEditingController(text: news.newsText);
    String currentDate = DateTime.now().toString().split(' ')[0];
    String currentTime = TimeOfDay.now().format(context);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit News'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editNewsController,
                  decoration: InputDecoration(
                    hintText: 'Edit News Text',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter news text';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateNews(news.id!, _editNewsController.text, currentDate,
                      currentTime);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateNews(int id, String newText, String newDate, String newTime) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    News updatedNews = News(
      id: id,
      newsText: newText,
      newsDate: newDate,
      newsTime: newTime,
      ownerId: widget.userId,
    );
    await dbHelper.updateNews(updatedNews);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('News Updated Successfully'),
      ),
    );
    _loadNews();
  }



  void _deleteNews(BuildContext context, int newsId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete News'),
          content: Text('Are you sure you want to delete this news?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _confirmDeleteNews(newsId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteNews(int newsId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deleteNews(newsId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('News Deleted Successfully'),
      ),
    );
    _loadNews();
  }

}



