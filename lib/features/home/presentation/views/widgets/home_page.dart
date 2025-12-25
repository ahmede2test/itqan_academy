import 'package:flutter/material.dart';
import 'package:itqan_academy/core/widgets/hover_effect.dart';
import 'package:itqan_academy/core/widgets/responsive_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'PostDetailScreen.dart';
import '../../manger/post_cubit/post_cubit.dart';
import '../../manger/post_cubit/post_state.dart';
import 'NotificationsScreen.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _achievementFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PostCubit.get(context).getPosts();
        ProfileCubit.get(context).getProfileData(); // 🔄 Fetch Profile Data
      }
    });

    // Memoize the achievement future to prevent rebuild loops
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _achievementFuture = Supabase.instance.client
          .from('exam_results')
          .select('grade_letter')
          .eq('user_id', user.id)
          .then((value) => List<Map<String, dynamic>>.from(value as List));
    } else {
      _achievementFuture = Future.value([]);
    }
  }

  Widget shimmerPostCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget shimmerNewsCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/itqan_logo.png',
          height: 40,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Supabase.instance.client
                .from('academy_news')
                .stream(primaryKey: ['id']),
            builder: (context, snapshot) {
              // 1. جلب قائمة الـ IDs التي قمت بحذفها محلياً
              List<String> deletedIds = CashHelper.sharedPreference
                      .getStringList('deleted_news_ids') ??
                  [];

              // 2. فلترة البيانات القادمة من السيرفر: نحسب فقط الأخبار اللي "ليست" في القائمة السوداء
              final visibleNotifications = snapshot.data?.where((item) {
                    return !deletedIds.contains(item['id'].toString());
                  }).toList() ??
                  [];

              // 3. العدد الفعلي للإشعارات اللي المفروض تظهر للمستخدم
              int remoteCount = visibleNotifications.length;

              // 4. آخر عدد إشعارات شاهده المستخدم ومخزن في الهاتف
              int localCount =
                  CashHelper.getData('last_notification_count') ?? 0;

              // النقطة الحمراء تظهر فقط لو فيه إشعارات "جديدة" فعلاً وموجودة (غير ممسوحة)
              bool showRedDot = remoteCount > localCount;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 34,
                    ),
                    onPressed: () async {
                      // ✅ عند الضغط: نحدث 'localCount' ليتساوى مع عدد الإشعارات الظاهرة حالياً
                      await CashHelper.setData('last_notification_count', 0);

                      // تحديث الواجهة لإخفاء النقطة الحمراء فوراً
                      setState(() {});

                      // الذهاب لصفحة الإشعارات
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationsScreen()),
                        );
                      }
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),

                  // النقطة الحمراء تظهر بناءً على الفلترة الجديدة
                  if (showRedDot)
                    Positioned(
                      right: 18,
                      top: 15,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 10, minHeight: 10),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PostCubit, PostState>(
        listener: (context, state) {
          if (state is PostError) {
            customShowToast(msg: state.message);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await PostCubit.get(context).getPosts();
            },
            child: CustomScrollView(
              // 🚀 Using CustomScrollView for better performance
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🔹 Smart Name Logic
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileLoading) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[800]!,
                                          highlightColor: Colors.grey[700]!,
                                          child: Container(
                                            height: 24,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        );
                                      }
                                      String displayName = 'User';
                                      if (state is ProfileSuccess) {
                                        displayName = state.profileModel.name ??
                                            state.profileModel.firstName ??
                                            'User';
                                      } else {
                                        // Fallback logic
                                        displayName =
                                            CashHelper.getData('name') ??
                                                Supabase
                                                    .instance
                                                    .client
                                                    .auth
                                                    .currentUser
                                                    ?.userMetadata?['name'] ??
                                                'User';
                                      }

                                      return Text(
                                        '${S.of(context).hello} $displayName',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                          fontSize: 22, // Bigger & bolder
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    S.of(context).startYourTravel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Cairo',
                                      color: Colors.grey[400], // Subtle Grey
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Achievement Badge
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _achievementFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    !snapshot.hasData ||
                                    snapshot.data!.isEmpty)
                                  return const SizedBox();

                                final data = snapshot.data!;
                                double total = 0;
                                int count = 0;
                                for (var item in data) {
                                  final g =
                                      (item['grade_letter'] as String? ?? 'F')
                                          .toUpperCase();
                                  if (g.startsWith('A'))
                                    total += 4;
                                  else if (g.startsWith('B'))
                                    total += 3;
                                  else if (g.startsWith('C'))
                                    total += 2;
                                  else if (g.startsWith('D')) total += 1;
                                  count++;
                                }
                                if (count == 0) return const SizedBox();
                                final avg = total / count;
                                String badge = 'Learner';
                                Color color = Colors.grey;
                                IconData icon = Icons.school;

                                if (avg >= 3.5) {
                                  badge = 'Elite';
                                  color = Colors.amber;
                                  icon = Icons.workspace_premium;
                                } else if (avg >= 2.5) {
                                  badge = 'Advanced';
                                  color = Colors.blueAccent;
                                  icon = Icons.verified;
                                } else {
                                  badge = 'Rising';
                                  color = Colors.green;
                                  icon = Icons.trending_up;
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: color.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(icon, color: color, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        badge,
                                        style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Cairo'),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// ✅ سلايدر البوستات
                SliverToBoxAdapter(
                  child: state is PostSuccess
                      ? SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: state.posts.length,
                            controller: PageController(viewportFraction: 0.9),
                            itemBuilder: (_, index) {
                              final post = state.posts[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PostDetailScreen(post: post),
                                  ),
                                ),
                                child: HoverEffect(
                                  scale: 1.02,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      image: post.featuredImage != null
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  post.featuredImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/image-error.png'),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.black,
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      alignment: isArabic()
                                          ? Alignment.bottomRight
                                          : Alignment.bottomLeft,
                                      child: Text(
                                        post.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'cairo',
                                          shadows: [
                                            Shadow(
                                              blurRadius: 5,
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : state is PostError
                          ? Center(
                              child: Text(state.message,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Cairo')))
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                height: 200,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (_, __) => SizedBox(
                                    width: 320,
                                    child: shimmerPostCard(),
                                  ),
                                ),
                              ),
                            ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                    child: Row(
                      children: [
                        Text(
                          S.of(context).latestNews,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.local_fire_department_sharp,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                if (state is PostSuccess)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveLayout.isDesktop(context)
                            ? 4
                            : ResponsiveLayout.isTablet(context)
                                ? 3
                                : 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = state.posts[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailScreen(post: post),
                              ),
                            ),
                            child: HoverEffect(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: post.featuredImage != null
                                          ? CachedNetworkImage(
                                              imageUrl: post.featuredImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              placeholder: (context, url) =>
                                                  shimmerNewsCard(),
                                              errorWidget: (_, __, ___) =>
                                                  const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white24,
                                                ),
                                              ),
                                            )
                                          : Image.asset(
                                              'assets/images/image-error.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        post.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'cairo',
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: state.posts.length,
                      ),
                    ),
                  )
                else if (state is PostError)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text(state.message,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Cairo')),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => shimmerNewsCard(),
                        childCount: 6,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}
