import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/app_scope.dart';
import 'package:adhd_cbt_app/content/content_runtime.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/screens/session_screen.dart';

Session _mkSessionWithEvidence() => Session(
    id: 's1',
    order: 1,
    module: 'psychoeducation',
    title: 'Understanding ADHD',
    checkpoints: [
      Checkpoint(
        id: 'c0',
        type: CheckpointType.reading,
        title: 'About ADHD',
        content: ['ADHD is a real, biological condition.'],
        evidence: [
          EvidenceItem(
            source: 'safren-2010-cbt-rct',
            claimEn: 'CBT can help when medication is not enough.',
            claimTr: 'BDT ilaç yetmediğinde yardımcı olabilir.',
          ),
          EvidenceItem(
            source: 'barkley-2015',
            claimEn: 'Core domains: attention, impulsivity, activity.',
          ),
        ],
      ),
    ]);

void main() {
  testWidgets('renders evidence supercripts [1][2] on read-evidence-style checkpoint',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          forms: null,
          sources: [
            SourceInfo(id: 'safren-2010-cbt-rct', author: 'Safren et al.',
                       year: 2010, title: 'CBT for Adult ADHD',
                       publication: 'JAMA', sourceType: 'rct',
                       accessStatus: 'verified_accessible',
                       evidenceRole: 'efficacy_evidence',
                       doi: '10.1001/jama.2010.1192', pmid: '20736471'),
            SourceInfo(id: 'barkley-2015', author: 'Barkley',
                       year: 2015, title: 'ADHD Handbook',
                       publication: 'Guilford', sourceType: 'handbook',
                       accessStatus: 'verified_accessible',
                       evidenceRole: 'mechanism', isbn: '9781462517725'),
          ],
          child: SessionScreen(session: _mkSessionWithEvidence()),
        ),
      ),
    );
    expect(find.text('ADHD is a real, biological condition.'), findsOneWidget);
    // Two evidence items -> two supercripts
    expect(find.text('[1]'), findsOneWidget);
    expect(find.text('[2]'), findsOneWidget);
  });

  testWidgets('tapping a superscript opens source card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          forms: null,
          sources: [
            SourceInfo(id: 'safren-2010-cbt-rct', author: 'Safren et al.',
                       year: 2010, title: 'CBT for Adult ADHD',
                       publication: 'JAMA', sourceType: 'rct',
                       accessStatus: 'verified_accessible',
                       evidenceRole: 'efficacy_evidence',
                       doi: '10.1001/jama.2010.1192', pmid: '20736471'),
          ],
          child: SessionScreen(session: _mkSessionWithEvidence()),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('[1]'), findsOneWidget);
    await tester.tap(find.text('[1]'));
    await tester.pumpAndSettle();
    // Source card shows title + author + DOI (claim falls back to EN)
    expect(find.text('CBT for Adult ADHD'), findsOneWidget);
    expect(find.text('Safren et al.'), findsOneWidget);
    expect(find.text('10.1001/jama.2010.1192'), findsOneWidget);
  });

  testWidgets('checkpoint without evidence renders no supercripts',
      (tester) async {
    final session = Session(
        id: 's1', order: 1, module: 'psychoeducation', title: 'T',
        checkpoints: [
          Checkpoint(id: 'c0', type: CheckpointType.reading,
                     title: 'T', content: ['Body'], evidence: null),
        ]);
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(forms: null, sources: [],
                       child: SessionScreen(session: session)),
      ),
    );
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('[1]'), findsNothing);
    expect(find.text('[2]'), findsNothing);
  });
}
