import '../models/story.dart';

final List<String> sampleMountainImages = [
  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80', // Merbabu green hill savanna
  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80', // Prau golden sunrise
  'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1200&q=80', // Rinjani crater lake
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80', // Snowy starry mountain peak
];

final List<StoryPost> initialStories = [
  StoryPost(
    id: 'post_1',
    authorName: 'Alya Putri',
    authorAvatar:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    mountain: 'Merbabu',
    date: '12 Okt 2025 · Data contoh',
    content:
        'Bukan soal cepat sampai. Istirahat di Pos 3, saling tunggu, lalu pulang dengan cerita. 🌿\n\nApa pelajaran dari pendakian pertamamu?',
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80',
    likesCount: 24,
    isLiked: false,
    category: 'Untukmu',
    isCurrentUser: true,
    comments: [
      StoryComment(
        id: 'c1_1',
        authorName: 'Raka Pratama',
        timestamp: '12 Okt · 14.20',
        content: 'Pelan-pelan, yang penting semua pulang aman.',
      ),
      StoryComment(
        id: 'c1_2',
        authorName: 'Nadia Rahma',
        timestamp: '12 Okt · 14.35',
        content: 'Setuju! Jas hujan jangan sampai ketinggalan.',
      ),
      StoryComment(
        id: 'c1_3',
        authorName: 'Alya Putri',
        timestamp: '12 Okt · 15.02',
        content: 'Betul, saling cek perlengkapan sebelum mulai.',
      ),
    ],
  ),
  StoryPost(
    id: 'post_2',
    authorName: 'Nadia Rahma',
    authorAvatar:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
    mountain: 'Prau',
    date: '21 Sep 2026 · Data contoh',
    content:
        'Prau mengajarkan: lapisan hangat dan teman yang saling jaga itu penting. Apa barang wajibmu?',
    imageUrl:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
    likesCount: 18,
    isLiked: false,
    category: 'Terbaru',
    isCurrentUser: false,
    comments: [
      StoryComment(
        id: 'c2_1',
        authorName: 'Bayu Wicaksono',
        timestamp: '21 Sep · 08.15',
        content:
            'Matras aluminium foil dan sleeping bag bulu angsa penyelamat dingin Prau!',
      ),
      StoryComment(
        id: 'c2_2',
        authorName: 'Alya Putri',
        timestamp: '21 Sep · 09.30',
        content:
            'Thermos kecil isi teh hangat jahe pas sampai puncak surga banget.',
      ),
    ],
  ),
  StoryPost(
    id: 'post_3',
    authorName: 'Raka Pratama',
    authorAvatar:
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=200&q=80',
    mountain: 'Rinjani',
    date: '05 Agu 2026 · Data contoh',
    content:
        'Tips pemula: Jangan remehkan hidrasi saat summit attack. Bawa minimal 1.5L air dan elektrolit. Dan yang paling penting: bawa turun sampahmu! 🎒⛰️',
    imageUrl:
        'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1200&q=80',
    likesCount: 42,
    isLiked: true,
    category: 'Tips pemula',
    isCurrentUser: false,
    comments: [
      StoryComment(
        id: 'c3_1',
        authorName: 'Fajar Nugraha',
        timestamp: '05 Agu · 11.00',
        content:
            'Rinjani luar biasa megah. Sampah plastik memang musuh utama, wajib clean up.',
      ),
    ],
  ),
];
