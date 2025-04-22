import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class MoodJournalWriting extends StatefulWidget {
  const MoodJournalWriting({super.key});

  @override
  State<MoodJournalWriting> createState() => _MoodJournalWritingState();
}

enum Mood { happy, neutral, sad }

enum JournalCategory {
  Work,
  Exercise,
  Family,
  Hobbies,
  Finances,
  Sleep,
  Drink,
  Food,
  RelationShip,
  Education,
  Weather,
  Music,
  Travel,
  Health,
}

class _MoodJournalWritingState extends State<MoodJournalWriting> {
  JournalCategory? selectedJournalCategory;
  Mood? selectedMood;
  String _journalTitle = "";
  String _journalContent = "";
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood Journal',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.clockRotateLeft),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'How are you feeling?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoodLottie(
                    path: 'assets/lotties/sadface.json',
                    mood: Mood.sad,
                    label: 'Sad',
                  ),
                  _buildMoodLottie(
                    path: 'assets/lotties/neutralface.json',
                    mood: Mood.neutral,
                    label: 'Neutral',
                  ),
                  _buildMoodLottie(
                    path: 'assets/lotties/happyface.json',
                    mood: Mood.happy,
                    label: 'Happy',
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: 1,
                children: [
                  _buildJournalCategory(journalCategory: JournalCategory.Work),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Exercise,
                  ),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Family,
                  ),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Hobbies,
                  ),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Finances,
                  ),
                  _buildJournalCategory(journalCategory: JournalCategory.Sleep),
                  _buildJournalCategory(journalCategory: JournalCategory.Drink),
                  _buildJournalCategory(journalCategory: JournalCategory.Food),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.RelationShip,
                  ),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Education,
                  ),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Weather,
                  ),
                  _buildJournalCategory(journalCategory: JournalCategory.Music),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Travel,
                  ),
                  _buildJournalCategory(
                    journalCategory: JournalCategory.Health,
                  ),
                ],
              ),
              SizedBox(height: 1),
              Align(
                alignment: Alignment.centerLeft,

                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.06,
                    top: screenHeight * 0.02,
                  ),
                  child: Text(
                    'Journal Title',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your journal title here',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _journalTitle = value;
                    });
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),

                child: TextField(
                  minLines: 5,
                  maxLines: null,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'How is your day going? How has it affected your mood? Or anything else...',
                    filled: true,
                    fillColor: Color(0xFF9bb168),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black87, width: 3), //
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black87, width: 3), //
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _journalContent = value;
                    });
                  },
                ),
              ),
              SizedBox(height: screenHeight*0.01),
              ElevatedButton(
                onPressed: () {
                  // Handle logging mood
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4f3422),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06), // Responsive size
                ),
                child: Text(
                  'Log mood',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600// Responsive font size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodLottie({
    required String path,
    required Mood mood,
    required String label,
  }) {
    final isSelected = selectedMood == mood;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              selectedMood = mood;
            });
          },
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.yellow[50]! : Colors.grey[600]!,
                BlendMode.modulate,
              ),
              child: Lottie.asset(path, repeat: isSelected, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.orangeAccent : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildJournalCategory({required JournalCategory journalCategory}) {
    final isSelected = selectedJournalCategory == journalCategory;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedJournalCategory = journalCategory;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF9bb168) : const Color(0xFFEAf8fe),
        foregroundColor: Colors.black87,
        elevation: isSelected ? 15 : 0,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: Colors.black87, width: 2.5),
        ),
      ),
      child: Text(
        journalCategory.name,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      ),
    );
  }

}
