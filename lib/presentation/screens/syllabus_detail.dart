// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/presentation/wighets/build_section.dart';
import 'package:flutter/material.dart';

class SyllabusDetail extends StatelessWidget {
  const SyllabusDetail({
    super.key,
    required this.getSyllabus,
    required this.syllabus,
  });
  final GetSyllabus getSyllabus;
  final ClassSyllabus syllabus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(syllabus.subject),
      ),
      body: FutureBuilder(
        future: getSyllabus.getSyllabusDetail(syllabus),
        builder: (
          BuildContext context,
          AsyncSnapshot<ClassSyllabusDetail> snapshot,
        ) {
          if (snapshot.hasData) {
            final classSyllabusDetail = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(classSyllabusDetail.classRoom),
                    Text(
                      '${classSyllabusDetail.classification.displayName} ${classSyllabusDetail.unitsNumber}単位    ${classSyllabusDetail.semester} ${classSyllabusDetail.classPeriod}',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                for (var i = 0;
                    i < classSyllabusDetail.teacher.length;
                    i++) ...{
                  Text(
                    '${classSyllabusDetail.teacher[i]} ${classSyllabusDetail.teacherRuby[i]}',
                  ),
                },
                BuildSection(title: '概要', content: classSyllabusDetail.content),
                BuildSection(
                  title: '計画',
                  content: [classSyllabusDetail.plan.join('\n')],
                ),
                BuildSection(
                  title: '学習到達目標',
                  content: [classSyllabusDetail.learningGoal],
                ),
                BuildSection(
                  title: '方法と特徴',
                  content: [classSyllabusDetail.features],
                ),
                BuildSection(
                  title: '成績評価',
                  content: [classSyllabusDetail.records],
                ),
                if (classSyllabusDetail.teachersMessage.isNotEmpty) ...{
                  BuildSection(
                    title: '教員メッセージ',
                    content: [classSyllabusDetail.teachersMessage],
                  ),
                },
                BuildSection(
                  title: '教科書',
                  content: [classSyllabusDetail.textBook],
                ),
                if (classSyllabusDetail.referenceBook.isNotEmpty) ...{
                  BuildSection(
                    title: '参考書',
                    content: [classSyllabusDetail.referenceBook],
                  ),
                },
                const SizedBox(
                  height: 10,
                ),
              ],
            );
          } else if (snapshot.hasError) {
            if (snapshot.error is SocketException) {
              return const Center(
                child: Text(
                  'インターネットに接続できません',
                ),
              );
            }
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          } else {
            return const Center(
              child: SizedBox(
                height: 25, //指定
                width: 25, //指定
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
