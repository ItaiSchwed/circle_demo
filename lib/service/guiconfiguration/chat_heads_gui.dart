/*
import 'dart:core';


import 'package:circle_demo/service/guiconfiguration/igui_configuration.dart';
import 'package:circle_demo/service/utilities/enums/side.dart';
import 'package:circle_demo/service/utilities/enums/tl_color.dart';
import 'package:flutter/material.dart';

class ChatHeadsGui implements IGUIConfiguration {

  BuildContext _context;

  /// todo
//  WindowManager _windowManager;
//  List<RelativeLayout> _layouts = List();
//  LayoutInflater _inflater;

  static int _MARGIN;
  static int _CIRCLE_SIZE;
//    private static int WINDOW_HEIGHT;
  static int _WINDOW_WIDTH;
  static int _ARROW_START_FROM_SIDE;
  static int _ARROW_FINE_SIZE;
//    private static int ARROW_START_FROM_TOP;
  static int _ARROW_LARGE_SIZE;
  static int _ARROW_START_FROM_CIRCLE;
  static int _CIRCLE_START_FROM_SIDE;
  static int _CIRCLE_START_FROM_TOP;

  ///todo
//  RelativeLayout _relativeLayout;
//  RelativeLayout _deleteLayout;


  Map<Side, bool> f;

  Map<Side, bool> _existsMap = {};
  Map<Side, bool> _isGreenMap = {};
  Map<Side, Map<TLColor, double>> _totalTimes;
  Map<Side, Widget> _chatHeadsMap = {};
  Map<Side, Widget> _arrowsMap = {};
  Map<Side, CircleDisplay> _circlesMap = {};

  Widget _deleteSing;

  WindowManager.LayoutParams _layoutParams;
  WindowManager.LayoutParams _deleteLayoutParams;

  ChatHeadsGui(this._context);


  //Setters and getters
  void _setIsGreenMap(Side side, bool isGreen) {
    _isGreenMap.put(side, isGreen);
  }
  private boolean getIsGreenMap(Side side){
    return isGreenMap.get(side);
  }

  private void setExistsMap(Side side, boolean exist) {
    existsMap.put(side, exist);
  }
  private boolean getExistsMap(Side side){
    return existsMap.get(side);
  }

  //Animator
  class TLIAnimatorListener implements Animator.AnimatorListener{
  Side side;

  TLIAnimatorListener(Side side){
  this.side = side;
  }

  @Override
  public void onAnimationStart(Animator animation) {
  Log.d(Constants.TLI_SERVICE_TAG, "animation starts");
  }

  @Override
  public void onAnimationEnd(Animator animation) {
  /*Vibrator vibrator;
                vibrator = (Vibrator)chatHeadsService.getSystemService(Context.VIBRATOR_SERVICE);
                vibrator.vibrate(500);*/
  Log.d(Constants.TLI_SERVICE_TAG, "animation end");
  setIsGreenMap(side, !getIsGreenMap(side));
  changeState(side);
  }

  @Override
  public void onAnimationCancel(Animator animation) {

  }

  @Override
  public void onAnimationRepeat(Animator animation) {

  }
  }
  private void changeState(Side side) {
  if (!getExistsMap(side)) return;
  TLColor color = (getIsGreenMap(side) ? GREEN : TLColor.RED);
  circlesMap.put(side, getExistsCircle(chatHeadsMap.get(side), color, totalTimes.get(side).get(color), side));
  }

  @Override
  public void restart(Map<Side, Map<TLColor, Long>> totalTimes){
  initializeFields(totalTimes);
  beginSetters();
  startAnimation();
  }

  private void initializeFields(Map<Side, Map<TLColor, Long>> totalTimes) {
  this.totalTimes = totalTimes;
  }

  // setters
  private void beginSetters(){
  setWindowComponents();
  setConstant();
  setExistFlags(totalTimes);
  setColorFlags(new HashMap<Side, TLColor>(){{
  put(Side.LEFT, TLColor.GREEN);
  put(Side.MIDDLE, TLColor.GREEN);
  put(Side.RIGHT, TLColor.GREEN);
  }});
  }
  private void setWindowComponents() {
  windowManager = (WindowManager) context.getSystemService(WINDOW_SERVICE);
  inflater = (LayoutInflater) context.getApplicationContext().getSystemService(LAYOUT_INFLATER_SERVICE);
  }
  private void setConstant() {
  Point size = new Point();
  //1080
  //1920
  windowManager.getDefaultDisplay().getSize(size);
//        int WINDOW_HEIGHT = size.y;
  WINDOW_WIDTH = size.x;
  MARGIN = (int) (WINDOW_WIDTH * 0.1);
  CIRCLE_SIZE = (int) (WINDOW_WIDTH * 0.15);
  ARROW_FINE_SIZE = (int) (WINDOW_WIDTH * 0.1);
  ARROW_LARGE_SIZE = CIRCLE_SIZE;
  ARROW_START_FROM_SIDE = (int) (WINDOW_WIDTH * 0.05);
  int ARROW_START_FROM_TOP = 0;
  CIRCLE_START_FROM_SIDE = (int) (WINDOW_WIDTH * 0.175);
  ARROW_START_FROM_CIRCLE = ((CIRCLE_START_FROM_SIDE - ARROW_START_FROM_SIDE) - ARROW_FINE_SIZE);
  CIRCLE_START_FROM_TOP = ARROW_START_FROM_TOP + ARROW_FINE_SIZE + ARROW_START_FROM_CIRCLE;
  }
  private void setColorFlags(Map<Side, TLColor> updatedDataMap){
  for (Side side : Side.values())
  setIsGreenMap(side, updatedDataMap.get(side) == TLColor.GREEN);
  }
  private void setExistFlags(Map<Side, Map<TLColor, Long>> totalTimes) {
  for (Side side : Side.values())
  setExistsMap(side, totalTimes.get(side) != null);
  }

  //Animation
  private void startAnimation(){
  setAnimationSettings();
  setCirclesMap(totalTimes);
  setViews();
  addChatHeads();
  }

  //AnimationSettings
  @SuppressLint("RtlHardcoded")
  private void setAnimationSettings() {
  findAllViewsById();

  layoutParams = getLayoutParams(
  WINDOW_WIDTH,
  CIRCLE_SIZE + CIRCLE_START_FROM_TOP,
  Gravity.TOP | Gravity.CENTER,
  CIRCLE_SIZE/3,
  0);

  deleteLayoutParams = getLayoutParams(
  CIRCLE_SIZE/3,
  CIRCLE_SIZE,
  Gravity.TOP | Gravity.RIGHT,
  0,
  CIRCLE_START_FROM_TOP);

  deleteSing.setAlpha((float) 0.5);
  }

  @SuppressLint("InflateParams")
  private void findAllViewsById() {
  relativeLayout = (RelativeLayout) inflater.inflate(R.layout.untouchable_service_chat_head, null);
  deleteLayout = (RelativeLayout) inflater.inflate(R.layout.touchable_service_chat_head, null);

  chatHeadsMap.put(RIGHT, relativeLayout.findViewById(R.id.rightCircle));
  chatHeadsMap.put(MIDDLE, relativeLayout.findViewById(R.id.middleCircle));
  chatHeadsMap.put(LEFT, relativeLayout.findViewById(R.id.leftCircle));

  arrowsMap.put(RIGHT, relativeLayout.findViewById(R.id.rightArrow));
  arrowsMap.put(MIDDLE, relativeLayout.findViewById(R.id.middleArrow));
  arrowsMap.put(LEFT, relativeLayout.findViewById(R.id.leftArrow));

  deleteSing = deleteLayout.findViewById(R.id.delete);
  }
  private WindowManager.LayoutParams getLayoutParams(int layoutWidth, int layoutHight, int gravity, int x, int y) {
  WindowManager.LayoutParams layoutParams =
  new WindowManager.LayoutParams(
  layoutWidth, layoutHight,
  WindowManager.LayoutParams.TYPE_PHONE,
  WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE |
  WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
  PixelFormat.TRANSLUCENT);

  layoutParams.gravity = gravity;
  layoutParams.x = x;
  layoutParams.y = y;

  return layoutParams;
  }

  //Circles
  private void setCirclesMap(Map<Side, Map<TLColor, Long>> totalTimes){
  for (Side side : Side.values())
  circlesMap.put(side, getCircle(chatHeadsMap.get(side), totalTimes.get(side), side));
  }
  private CircleDisplay getCircle(View chatHead, Map<TLColor, Long> totalTimes, Side side){
  if (totalTimes == null) {
  return getNotExistsCircle(chatHead, side);
  }
  return getExistsCircle(chatHead, GREEN, totalTimes.get(GREEN), side);
  }
  private CircleDisplay getExistsCircle(View chatHead, TLColor color, long duration, final Side side) {

  CircleDisplay circle = findViewByIdAccordingSide(chatHead, side);

  if (circle != null) {
  circle.setAnimDuration((int) (duration * 1000));
  circle.setValueWidthPercent(35f);
  circle.setDimAlpha(250);
  circle.setTextSize(15f);
  circle.setFrontCircleColor(Color.LTGRAY);
  circle.setBackCircleColor(color.getColor());
  circle.setDrawText(true);
  circle.setDrawInnerCircle(true);
  circle.setFormatDigits(1);
  circle.setTouchEnabled(true);
  circle.setUnit("");
  circle.setStepSize(100f / duration);
  String[] strings = getStrings(duration);
  circle.setCustomText(strings);

  Animator.AnimatorListener animatorListener = new TLIAnimatorListener(side);
  circle.showValue(100f, 100f, animatorListener);

  return circle;
  }
  else{
  // TODO: 27 יולי 2018 throw exception
  return null;
  }
  }
  private CircleDisplay getNotExistsCircle(View chatHead, Side side) {
  CircleDisplay circle = findViewByIdAccordingSide(chatHead, side);

  if (circle != null) {
  circle.setValueWidthPercent(35f);
  circle.setFrontCircleColor(Color.GRAY);
  circle.setBackCircleColor(Color.GRAY);
  circle.setInnerCircleColor(Color.LTGRAY);
  circle.setDrawText(false);
  circle.setDrawInnerCircle(true);
  circle.setFormatDigits(1);
  circle.setTouchEnabled(true);
  circle.setUnit("");
  circle.setMinimumWidth((int) (WINDOW_WIDTH * 0.2));
  circle.setMinimumHeight((int) (WINDOW_WIDTH * 0.2));
  circle.setStepSize(100f);

  return circle;
  }
  else {
  // TODO: 27 יולי 2018 throw exception
  return null;
  }
  }
  private CircleDisplay findViewByIdAccordingSide(View chatHead, Side side) {
  switch (side) {
  case RIGHT:
  return chatHead.findViewById(R.id.rightCircle);
  case MIDDLE:
  return chatHead.findViewById(R.id.middleCircle);
  case LEFT:
  return chatHead.findViewById(R.id.leftCircle);
  default:
  // TODO: 27 יולי 2018 throw exception
  return null;
  }
  }
  private String[] getStrings(double duration) {
  String[] strings = new String[(int) duration];
  for (int i=0; i<duration; i++){
  strings[i] = String.valueOf((int) (duration - i));
  }
  return strings;
  }

  //Views
  private void setViews() {
  setDeleteSing();
  setChatHeads();
  setArrows();
  }

  //DeleteSing
  private void setDeleteSing() {
  setDeleteSingOnTouchListener();

  deleteSing.getLayoutParams().height = CIRCLE_SIZE;
  deleteSing.getLayoutParams().width = CIRCLE_SIZE/3;
  deleteSing.setX(0);
  deleteSing.setY(0);
  deleteSing.setClickable(true);
  }
  private void setDeleteSingOnTouchListener() {
  final AlphaAnimation alphaOnAnimation = new AlphaAnimation(1.0f, 0.0f);
  alphaOnAnimation.setDuration(500);

  final AlphaAnimation alphaOffAnimation = new AlphaAnimation(0.0f, 1.0f);
  alphaOffAnimation.setDuration(500);

  deleteSing.setOnTouchListener(new View.OnTouchListener() {
  boolean viewsAreShown = true;

  @SuppressLint("ClickableViewAccessibility")
  @Override
  public boolean onTouch(View v, MotionEvent event) {
  switch (event.getAction()) {
  case MotionEvent.ACTION_DOWN:
  if (viewsAreShown)
  hideImageView();
  else
  showImageView();
  return true;
  case MotionEvent.ACTION_UP: return true;
  case MotionEvent.ACTION_MOVE: return true;
  }
  return false;
  }

  private void showImageView() {
  viewsAreShown = true;

  Map<Side, Float> fromXMap = getXMap();

  Map<Side, Float> toXMap = new HashMap<>();
  for (Side side : Side.values()) {
  toXMap.put(side, (float) 0);
  }

  startAnimations(100, alphaOffAnimation, fromXMap, toXMap);

  setVisibility(View.VISIBLE);
  }
  private void hideImageView() {
  viewsAreShown = false;

  Map<Side, Float> fromXMap = new HashMap<>();
  for (Side side : Side.values()) {
  fromXMap.put(side, (float) 0);
  }

  Map<Side, Float> toXMap = getXMap();

  startAnimations(5000, alphaOnAnimation, fromXMap, toXMap);

  setVisibility(View.INVISIBLE);
  }

  private void setVisibility(int visible) {
  setChatHeadsVisibility(visible);
  setArrowsVisibility(visible);
  }
  private void setChatHeadsVisibility(int visible) {
  for (Side side : Side.values()) {
  chatHeadsMap.get(side).setVisibility(visible);
  }
  }
  private void setArrowsVisibility(int visible) {
  for (Side side : Side.values()) {
  arrowsMap.get(side).setVisibility(visible);
  }
  }

  private void startAnimations(int duration, Animation alphaAnimation,
  Map<Side, Float> fromX,
  Map<Side, Float> toX) {

  startChatHeadsAnimations(duration, fromX, toX);
  startArrowsAnimations(alphaAnimation);
  }
  private void startChatHeadsAnimations(int duration,
  Map<Side, Float> fromX,
  Map<Side, Float> toX) {
  for (Side side : Side.values()) {
  TranslateAnimation animation = getTranslateAnimation(fromX.get(side), toX.get(side));
  animation.setDuration(duration);
  chatHeadsMap.get(side).startAnimation(animation);
  }
  }
  private void startArrowsAnimations(Animation alphaAnimation) {
  for (Side side : Side.values()) {
  arrowsMap.get(side).startAnimation(alphaAnimation);
  }
  }

  private TranslateAnimation getTranslateAnimation(float fromX, float toX) {
  return new TranslateAnimation(
  Animation.RELATIVE_TO_SELF, fromX,
  Animation.RELATIVE_TO_SELF, toX,
  Animation.RELATIVE_TO_SELF, 0,
  Animation.RELATIVE_TO_SELF, 0);
  }

  });
  }

  //ChatHeads
  private void setChatHeads() {
  Map<Side, Float> xMap = getXMap();

  for (Side side : Side.values())
  setChatHead(chatHeadsMap.get(side), xMap.get(side));
  }
  @NonNull
  private Map<Side, Float> getXMap() {
  Map<Side, Float> xMap = new HashMap<>();

  xMap.put(RIGHT, (float) -(CIRCLE_START_FROM_SIDE));
  xMap.put(MIDDLE, (float) -(CIRCLE_START_FROM_SIDE + CIRCLE_SIZE + MARGIN));
  xMap.put(LEFT, (float) -(CIRCLE_START_FROM_SIDE + 2 * (CIRCLE_SIZE + MARGIN)));
  return xMap;
  }
  private void setChatHead(View chatHead, float x) {
  chatHead.setMinimumWidth(CIRCLE_SIZE);
  chatHead.setMinimumHeight(CIRCLE_SIZE);
  chatHead.setX(x);
  chatHead.setY(CIRCLE_START_FROM_TOP);
  RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(CIRCLE_SIZE, CIRCLE_SIZE);
  layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP | RelativeLayout.ALIGN_PARENT_RIGHT, relativeLayout.getId());
  chatHead.setLayoutParams(layoutParams);
  }

  //Arrows
  private void setArrows() {
  Map<Side, Float> arrowX = new HashMap<>();
  Map<Side, Float> arrowY = new HashMap<>();

  arrowX.put(RIGHT, (float) -ARROW_START_FROM_SIDE);
  arrowY.put(RIGHT, chatHeadsMap.get(RIGHT).getY() + (CIRCLE_SIZE / 2) - (ARROW_LARGE_SIZE / 2));

  arrowX.put(MIDDLE, chatHeadsMap.get(MIDDLE).getX() + (CIRCLE_SIZE / 2) - (ARROW_LARGE_SIZE / 2));
  arrowY.put(MIDDLE, (float) 0);

  arrowX.put(LEFT, chatHeadsMap.get(LEFT).getX() - CIRCLE_SIZE - ARROW_START_FROM_CIRCLE);
  arrowY.put(LEFT, chatHeadsMap.get(LEFT).getY() + (CIRCLE_SIZE/2) - (ARROW_LARGE_SIZE/2));

  for (Side side : Side.values()) {
  setArrow(arrowsMap.get(side), arrowX.get(side), arrowY.get(side));
  }
  }
  private void setArrow(View arrow, float ArrowX, float ArrowY) {
  arrow.setMinimumHeight(ARROW_LARGE_SIZE);
  arrow.setMinimumWidth(ARROW_FINE_SIZE);
  arrow.setX(ArrowX);
  arrow.setY(ArrowY);
  }

  //addLayouts
  private void addChatHeads() {
  addChatHead(relativeLayout, this.layoutParams);
  addChatHead(deleteLayout, this.deleteLayoutParams);
  }
  private void addChatHead(RelativeLayout chatHeadLayout, ViewGroup.LayoutParams params) {
  layouts.add(chatHeadLayout);
  windowManager.addView(chatHeadLayout, params);
  }

  @Override
  public void update(IUpdatedData updatedData, Side side) throws ColorException, LightChangedException {
  isGreenMap.put(side, updatedData.getTLColor() == TLColor.GREEN);
  circlesMap.get(side).setAnimDuration(updatedData.getRealTimeSecondsToSwitch());
  circlesMap.get(side).showValue(getPercentToShow(updatedData, side), 100f, new TLIAnimatorListener(side));
  }
  private float getPercentToShow(IUpdatedData updatedData, Side side) throws LightChangedException, ColorException {
  return 100f - updatedData.getRealTimeSecondsToSwitch()/totalTimes.get(side).get(updatedData.getTLColor());
  }

  @Override
  public void stop() {
  removeLayouts();
  stopAnims();
  }

  //Remove anims
  private void stopAnims() {
  for (Side side : Side.values())
  circlesMap.get(side).stopAnim();
  }

  //Remove layouts
  private void removeLayouts() {
  for (RelativeLayout layout : layouts)
  removeLayout(layout);
  }
  private void removeLayout(RelativeLayout layout) {
  windowManager.removeView(layout);
  layouts.remove(layout);
  }
}
*/