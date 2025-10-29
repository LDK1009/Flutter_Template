import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torch_light/torch_light.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';

////////// 마법 주문 데이터
final List<Map<String, dynamic>> spellData = [
  {
    "spell": "오큘러스 레파로",
    "sound": "audio/occulus_reparo.mp3",
    "description": "부서진 안경을 고치는 주문",
  },
  {
    "spell": "알로호모라",
    "sound": "audio/alohomora.mp3",
    "description": "잠긴 문이나 자물쇠를 열 수 있는 해체 주문",
  },
  {
    "spell": "윙가르디움 레비오우사",
    "sound": "audio/wingardium_leviosa.mp3",
    "description": "물체를 공중에 띄우는 주문",
  },
  {
    "spell": "라카르넘 인플라모레",
    "sound": "audio/lacarnum_inflamari.mp3",
    "description": "지팡이 끝에서 불을 만들어내는 마법",
  },
  {
    "spell": "패트리피쿠스 토탈루스",
    "sound": "audio/petrificus_totalus.mp3",
    "description": "대상의 몸을 굳게 만드는 주문",
  },
  {
    "spell": "루모스",
    "sound": "audio/lumos.mp3",
    "description": "불을 켜는 주문",
  },
  {
    "spell": "녹스",
    "sound": "audio/nox.mp3",
    "description": "불을 끄는 주문",
  },
  {
    "spell": "종료",
    "sound": null,
    "description": "음성 인식 중지",
  },
];

////////// 앱 진입점
void main() {
  runApp(MyApp());
}

//////////////////////////////////////////////////
////////// 최상위 앱 위젯 (전역 상태 제공자 설정)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(), // 전역 상태 생성
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

////////// 전역 상태 관리 클래스
class MyAppState extends ChangeNotifier {}

//////////////////////////////////////////////////
////////// 마이 홈 페이지
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

////////// 마이 홈 페이지 상태 관리
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // 선택된 탭 인덱스

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainPage(),
    );
  }
}

////////// 메인 페이지
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

////////// 메인 페이지 상태
class _MainPageState extends State<MainPage> {
  var _speech = stt.SpeechToText(); // 음성 인식 객체
  final _audioPlayer = AudioPlayer(); // 오디오 플레이어 객체

  // 마법 주문 리스트
  late final List<Map<String, dynamic>> magicList;

  // 상태 변수들
  bool _isTorchOn = false; // 플래시 켜짐/꺼짐 상태
  bool _isListening = false; // 음성 인식 활성 여부
  String _lastWords = ''; // 마지막으로 인식한 단어

  // 마운트
  @override
  void initState() {
    super.initState();

    // 마법 주문 리스트 초기화 (spellData 기반으로 action 추가)
    magicList = spellData.map((spell) {
      var spellCopy = Map<String, dynamic>.from(spell);
      
      // 특정 주문에 action 연결
      if (spell["spell"] == "루모스") {
        spellCopy["action"] = _lumos;
      } else if (spell["spell"] == "녹스") {
        spellCopy["action"] = _nox;
      } else if (spell["spell"] == "종료") {
        spellCopy["action"] = _stopListening;
      } else {
        spellCopy["action"] = null;
      }
      
      return spellCopy;
    }).toList();

    _listen(); // 음성 인식 시작
  }

  // 디스포즈
  @override
  void dispose() {
    _audioPlayer.dispose(); // 오디오 플레이어 리소스 해제
    super.dispose();
  }

  /// 음성 인식 시작/중지
  Future<void> _listen() async {
    /// 음성 인식 가능한지 확인
    bool available = await _speech.initialize();
    if (!available) {
      return;
    }

    // 음성인식 상태 변경
    setState(() {
      _isListening = true;
    });

    // 음성인식 시작 (연속 인식)
    _speech.listen(
      onResult: (result) {
        /// 인식한 단어
        final recognizedWords = result.recognizedWords.toLowerCase();

        // 인식한 단어 저장
        setState(() {
          _lastWords = recognizedWords;
        });

        // 마법 주문 실행
        _executeMagicSpell(recognizedWords);

        if (result.finalResult) {
          print(recognizedWords);
        }

        // 최종 결과 출력 후 음성 인식 재시작
        if (result.finalResult && _isListening) {
          _listen();
        }
      },
      listenFor: Duration(hours: 24), // 24시간 동안 계속 듣기
      pauseFor: Duration(hours: 24), // 침묵해도 종료 안 함
    );
  }

  /// 음성 인식 중지
  Future<void> _stopListening() async {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // 음성 인식 토글
  Future<void> _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      _listen();
    }
  }

// 마법 주문 실행
  Future<void> _executeMagicSpell(String speechWords) async {
    for (var magic in magicList) {
      /// 마법 주문 일치 여부 확인
      if (speechWords.contains(magic["spell"])) {
        // 마법 주문 소리 재생 (action 실행 전에 먼저 재생)
        if (magic["sound"] != null) {
          await _playMagicSound(magic["sound"]);
        }

        // 마법 주문이 있는 경우 액션 실행
        if (magic["action"] != null) {
          await magic["action"]();
        }
        
        return;
      }
    }
  }

  /// 마법 주문 소리 재생
  Future<void> _playMagicSound(String sound) async {
    try {
      // 이전 재생 중지 및 초기화
      await _audioPlayer.stop();
      
      // 오디오 재생
      await _audioPlayer.play(AssetSource(sound));
    } catch (e) {
      print('오디오 재생 오류: $e');
    }
  }

  /// 루모스 주문 실행
  Future<void> _lumos() async {
    if (!_isTorchOn) {
      await TorchLight.enableTorch();
      setState(() {
        _isTorchOn = true;
      });
    }
  }

  /// 녹스 주문 실행
  Future<void> _nox() async {
    if (_isTorchOn) {
      await TorchLight.disableTorch();
      setState(() {
        _isTorchOn = false;
      });
    }
  }

  /// 플래시를 지정 시간만큼 켜고 끄기
  Future<void> _flashWithDelay(int milliseconds) async {
    await TorchLight.enableTorch();
    await Future.delayed(Duration(milliseconds: milliseconds));
    await TorchLight.disableTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/hogwarts.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 메인 콘텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 사이즈 박스 10px
                SizedBox(height: 10),

                // 마법 주문 버튼
                ElevatedButton.icon(
                  onPressed: _toggleListening,
                  icon: Icon(Icons.auto_fix_high),
                  label: Text(_isListening ? '마법 쓰는 중...' : '마법 쓰기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Color(0xFFFFB300) : Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: _isListening ? Colors.amber.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5),
                  ),
                ),

                // 인식한 음성 텍스트 표시
                if (_isListening && _lastWords.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      _lastWords,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 주문서 아이콘 (우측 상단)
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SpellBookModal();
                  },
                );
              },
              backgroundColor: Color(0xFFFF8F00),
              child: Icon(Icons.menu_book, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

////////// 주문서 모달
class SpellBookModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📖 마법 주문서',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Divider(thickness: 2),
            SizedBox(height: 10),
            
            // 주문 리스트
            Expanded(
              child: ListView.builder(
                itemCount: spellData.length,
                itemBuilder: (context, index) {
                  final spell = spellData[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.auto_fix_high, color: Colors.white),
                      ),
                      title: Text(
                        spell["spell"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          spell["description"],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
