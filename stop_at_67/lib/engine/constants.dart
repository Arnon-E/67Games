import 'dart:math';
import 'package:flutter/material.dart';
import 'types.dart';

// ============================================================
// GAME MODES
// ============================================================

const Map<String, GameMode> kGameModes = {
  'classic': GameMode(
    id: 'classic',
    name: 'Classic',
    targetMs: 6700,
    displayTarget: '6.700s',
    description: 'Stop the timer at exactly 6.7 seconds',
  ),
  'extended': GameMode(
    id: 'extended',
    name: 'Extended',
    targetMs: 67000,
    displayTarget: '67.000s',
    description: 'The ultimate test - stop at 67 seconds',
    unlockCondition: UnlockCondition(type: 'score', modeId: 'classic', value: 900),
  ),
  'blind': GameMode(
    id: 'blind',
    name: 'Blind',
    targetMs: 6700,
    displayTarget: '6.700s',
    description: 'Timer hides after 3 seconds - trust your instincts',
    blindAfterMs: 3000,
    unlockCondition: UnlockCondition(type: 'games_played', value: 10),
  ),
  'reverse': GameMode(
    id: 'reverse',
    name: 'Reverse',
    targetMs: 3300,
    displayTarget: '3.300s',
    description: 'Countdown from 10 - stop at 3.3',
    countdown: true,
    countdownFrom: 10000,
    unlockCondition: UnlockCondition(type: 'score', modeId: 'extended', value: 800),
  ),
  'reverse100': GameMode(
    id: 'reverse100',
    name: 'Reverse 100',
    targetMs: 33000,
    displayTarget: '33.000s',
    description: 'Countdown from 100 - stop at 33',
    countdown: true,
    countdownFrom: 100000,
    unlockCondition: UnlockCondition(type: 'score', modeId: 'reverse', value: 850),
  ),
  'daily': GameMode(
    id: 'daily',
    name: 'Daily Challenge',
    targetMs: 0,
    displayTarget: '?.???s',
    description: 'One attempt per day - compete globally',
    unlockCondition: UnlockCondition(type: 'games_played', value: 1),
  ),
  'surge': GameMode(
    id: 'surge',
    name: 'Surge',
    targetMs: 6700,
    displayTarget: '6.700s',
    description: 'Timer speeds up every game — how long can you keep up?',
    unlockCondition: UnlockCondition(type: 'games_played', value: 0),
  ),
};

// ============================================================
// RATING TIERS
// ============================================================

final List<({int maxDeviation, ScoreRating rating})> kRatingTiers = [
  (
    maxDeviation: 0,
    rating: const ScoreRating(
      tier: 'perfect',
      label: 'PERFECT!',
      color: Color(0xFFFFD700),
      emoji: '🏆',
      description: 'Absolute precision!',
    ),
  ),
  (
    maxDeviation: 10,
    rating: const ScoreRating(
      tier: 'incredible',
      label: 'INCREDIBLE',
      color: Color(0xFF00FF88),
      emoji: '⚡',
      description: 'Superhuman timing!',
    ),
  ),
  (
    maxDeviation: 50,
    rating: const ScoreRating(
      tier: 'excellent',
      label: 'EXCELLENT',
      color: Color(0xFF00DDFF),
      emoji: '🔥',
      description: 'Outstanding!',
    ),
  ),
  (
    maxDeviation: 100,
    rating: const ScoreRating(
      tier: 'great',
      label: 'GREAT',
      color: Color(0xFF88FF00),
      emoji: '✨',
      description: 'Really impressive!',
    ),
  ),
  (
    maxDeviation: 250,
    rating: const ScoreRating(
      tier: 'good',
      label: 'GOOD',
      color: Color(0xFFFFAA00),
      emoji: '👍',
      description: 'Nice work!',
    ),
  ),
  (
    maxDeviation: 500,
    rating: const ScoreRating(
      tier: 'ok',
      label: 'OK',
      color: Color(0xFFFF8800),
      emoji: '😅',
      description: 'Keep practicing!',
    ),
  ),
  (
    maxDeviation: 999999999,
    rating: const ScoreRating(
      tier: 'miss',
      label: 'MISS',
      color: Color(0xFFFF4444),
      emoji: '💨',
      description: 'Try again!',
    ),
  ),
];

// ============================================================
// ACHIEVEMENTS
// ============================================================

const List<Achievement> kAchievements = [
  Achievement(
    id: 'first_67',
    name: 'First 67',
    description: 'Complete your first game',
    icon: '🎮',
    rarity: 'common',
    condition: AchievementCondition(type: 'cumulative', metric: 'games_played', value: 1),
  ),
  Achievement(
    id: 'getting_started',
    name: 'Getting Started',
    description: 'Play 10 games',
    icon: '🚀',
    rarity: 'common',
    condition: AchievementCondition(type: 'cumulative', metric: 'games_played', value: 10),
  ),
  Achievement(
    id: 'dedicated',
    name: 'Dedicated',
    description: 'Play 100 games',
    icon: '💪',
    rarity: 'rare',
    condition: AchievementCondition(type: 'cumulative', metric: 'games_played', value: 100),
  ),
  Achievement(
    id: 'obsessed',
    name: 'Obsessed',
    description: 'Play 1000 games',
    icon: '🤯',
    rarity: 'legendary',
    condition: AchievementCondition(type: 'cumulative', metric: 'games_played', value: 1000),
  ),
  Achievement(
    id: 'sniper',
    name: 'Sniper',
    description: 'Hit within 10ms of the target',
    icon: '🎯',
    rarity: 'rare',
    condition: AchievementCondition(type: 'single_game', metric: 'deviation', value: 10),
  ),
  Achievement(
    id: 'perfect',
    name: 'Perfect',
    description: 'Hit exactly 6.700 or 67.000',
    icon: '💎',
    rarity: 'legendary',
    condition: AchievementCondition(type: 'single_game', metric: 'deviation', value: 0),
  ),
  Achievement(
    id: 'triple_excellent',
    name: 'Triple Excellent',
    description: 'Get 3 excellent ratings in a row',
    icon: '🌟',
    rarity: 'rare',
    condition: AchievementCondition(type: 'streak', metric: 'excellent_rating', value: 3),
  ),
  Achievement(
    id: 'hot_streak',
    name: 'Hot Streak',
    description: '5 games within 100ms',
    icon: '🔥',
    rarity: 'common',
    condition: AchievementCondition(type: 'streak', metric: 'within_100ms', value: 5),
  ),
  Achievement(
    id: 'streak_lord',
    name: 'Streak Lord',
    description: '10 games within 100ms',
    icon: '👑',
    rarity: 'epic',
    condition: AchievementCondition(type: 'streak', metric: 'within_100ms', value: 10),
  ),
  Achievement(
    id: 'unstoppable',
    name: 'Unstoppable',
    description: '25 games within 100ms',
    icon: '⚡',
    rarity: 'legendary',
    condition: AchievementCondition(type: 'streak', metric: 'within_100ms', value: 25),
  ),
  Achievement(
    id: 'blind_master',
    name: 'Blind Master',
    description: 'Score 900+ in Blind Mode',
    icon: '🙈',
    rarity: 'epic',
    condition: AchievementCondition(type: 'single_game', metric: 'score', value: 900, modeId: 'blind'),
  ),
  Achievement(
    id: 'extended_excellence',
    name: 'Extended Excellence',
    description: 'Score 950+ in Extended Mode',
    icon: '⏱️',
    rarity: 'epic',
    condition: AchievementCondition(type: 'single_game', metric: 'score', value: 950, modeId: 'extended'),
  ),
  Achievement(
    id: 'reverse_master',
    name: 'Reverse Master',
    description: 'Score 900+ in Reverse Mode',
    icon: '🔄',
    rarity: 'epic',
    condition: AchievementCondition(type: 'single_game', metric: 'score', value: 900, modeId: 'reverse'),
  ),
  Achievement(
    id: 'daily_player',
    name: 'Daily Player',
    description: 'Complete a daily challenge',
    icon: '📅',
    rarity: 'common',
    condition: AchievementCondition(type: 'cumulative', metric: 'daily_completed', value: 1),
  ),
  Achievement(
    id: 'daily_devotee',
    name: 'Daily Devotee',
    description: 'Complete 7 daily challenges in a row',
    icon: '🗓️',
    rarity: 'epic',
    condition: AchievementCondition(type: 'streak', metric: 'daily_streak', value: 7),
  ),
  Achievement(
    id: 'daily_champion',
    name: 'Daily Champion',
    description: 'Rank #1 in a daily challenge',
    icon: '🥇',
    rarity: 'legendary',
    condition: AchievementCondition(type: 'single_game', metric: 'daily_rank', value: 1),
  ),
  Achievement(
    id: '67_kid',
    name: '67 Kid',
    description: '???',
    icon: '🏀',
    rarity: 'legendary',
    condition: AchievementCondition(type: 'special', metric: 'easter_egg', value: 1),
  ),
];

// ============================================================
// STREAK CONFIG
// ============================================================

const kStreakConfig = (
  maintainThreshold: 100,
  breakThreshold: 500,
  maxMultiplier: 2.0,
  multiplierStep: 0.1,
);

// ============================================================
// SCORING CONFIG
// ============================================================

const kScoringConfig = (
  maxScore: 1000,
  xpDivisor: 10,
);

// ============================================================
// LEVEL PROGRESSION
// ============================================================

const kLevelConfig = (
  baseXp: 100,
  multiplier: 1.5,
  maxLevel: 100,
);

int xpForLevel(int level) => (kLevelConfig.baseXp * pow(kLevelConfig.multiplier, level - 1)).floor();

int totalXpForLevel(int level) {
  int total = 0;
  for (int i = 1; i < level; i++) {
    total += xpForLevel(i);
  }
  return total;
}

({int level, int currentXp, int nextLevelXp}) levelFromXp(int totalXp) {
  int level = 1;
  int remainingXp = totalXp;

  while (level < kLevelConfig.maxLevel) {
    final required = xpForLevel(level);
    if (remainingXp < required) {
      return (level: level, currentXp: remainingXp, nextLevelXp: required);
    }
    remainingXp -= required;
    level++;
  }

  return (level: kLevelConfig.maxLevel, currentXp: remainingXp, nextLevelXp: 0);
}
