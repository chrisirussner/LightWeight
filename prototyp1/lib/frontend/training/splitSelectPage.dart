import 'package:flutter/material.dart';
import '../../backend/training_http.dart';

class SplitSelectPage extends StatefulWidget {
  @override
  _SplitSelectPageState createState() => _SplitSelectPageState();
}

class _SplitSelectPageState extends State<SplitSelectPage> {
  late String selectedGoal;
  late String selectedLevel;
  late PageController _pageController;
  int _currentPageIndex = 0;
  late List<String> splits = ['split1', 'split2', 'split3', 'split4'];
  late Map<String, Map<String, List<String>>> splitData = {};
  bool isLoading = true; // Variable für das Laden-Status

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // Empfangen der Argumente beim Initialisieren der Seite
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Map<String, dynamic>? args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          selectedGoal = args['selectedGoal'];
          selectedLevel = args['selectedLevel'];
        });
        loadSplitData();
      }
    });
  }

  // Funktion zum Laden von Split-Daten unter Verwendung von splitNameForDay
  void loadSplitData() {
    for (String split in splits) {
      Map<String, List<String>> data = {};
      for (int i = 1; i <= 7; i++) {
        String day = 'day$i';
        splitNameForDay(selectedGoal, selectedLevel, split)
            .then((splitDataForDay) {
          // Daten nur für den aktuellen Tag hinzufügen
          String currentDayData = splitDataForDay[day] ?? 'Rest';
          data[day] = [currentDayData];
          // Wenn alle Daten für den aktuellen Split geladen wurden, setState aufrufen
          if (data.length == 7) {
            setState(() {
              splitData[split] = data;
              isLoading = false; // Laden abgeschlossen
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        toolbarHeight: 100,
        backgroundColor: Colors.black,
        title: Stack(
          alignment: Alignment.topRight,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/Logo_Menu_App.png',
                  fit: BoxFit.cover,
                  height: 60,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Light Weight',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/search_icon3.png',
                    height: 25,
                  ),
                  onPressed: () {
                    //do something
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/login_App.png',
                    height: 25,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/start');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: screenSize.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator()) // Ladesymbol anzeigen
                : Column(
                    children: [
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Split ${_currentPageIndex + 1}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 1; i <= 7; i++)
                                Column(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/splitSelectInfo',
                                          arguments: {
                                            'selectedGoal': selectedGoal,
                                            'selectedLevel': selectedLevel,
                                            'selectedSplit':
                                                splits[_currentPageIndex],
                                            'day': 'day$i',
                                            'planName': splitData[splits[
                                                        _currentPageIndex]]![
                                                    'day$i']!
                                                .first,
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Day $i | ${splitData[splits[_currentPageIndex]]!['day$i']!.first}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          Icon(Icons.arrow_forward,
                                              color: Colors.white),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Divider(color: Colors.white),
                                    SizedBox(height: 10),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  if (_currentPageIndex > 0) _currentPageIndex--;
                });
              },
            ),
            SizedBox(width: 20),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  if (_currentPageIndex < splits.length - 1)
                    _currentPageIndex++;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 50.0), // adjust this value according to your needs
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              DateTime currentDate = DateTime.now();
              String formattedDate =
                  '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
              String selectedSplit = splits[_currentPageIndex];
              saveSelectedTrainingPlan(context, selectedGoal, selectedLevel,
                  selectedSplit, formattedDate);
            },
            child: const Text('Select Split', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
