// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NewsModel {

 String get id; String get title; String get slug; String get category; String? get thumbnail; String get summary; String get content;@JsonKey(name: 'author') String get authorId;@JsonKey(name: 'expand') Map<String, dynamic>? get expand;@JsonKey(name: 'publish_date') DateTime get publishDate;@JsonKey(name: 'view_count') int get viewCount;
/// Create a copy of NewsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewsModelCopyWith<NewsModel> get copyWith => _$NewsModelCopyWithImpl<NewsModel>(this as NewsModel, _$identity);

  /// Serializes this NewsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.category, category) || other.category == category)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.content, content) || other.content == content)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&const DeepCollectionEquality().equals(other.expand, expand)&&(identical(other.publishDate, publishDate) || other.publishDate == publishDate)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,category,thumbnail,summary,content,authorId,const DeepCollectionEquality().hash(expand),publishDate,viewCount);

@override
String toString() {
  return 'NewsModel(id: $id, title: $title, slug: $slug, category: $category, thumbnail: $thumbnail, summary: $summary, content: $content, authorId: $authorId, expand: $expand, publishDate: $publishDate, viewCount: $viewCount)';
}


}

/// @nodoc
abstract mixin class $NewsModelCopyWith<$Res>  {
  factory $NewsModelCopyWith(NewsModel value, $Res Function(NewsModel) _then) = _$NewsModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String slug, String category, String? thumbnail, String summary, String content,@JsonKey(name: 'author') String authorId,@JsonKey(name: 'expand') Map<String, dynamic>? expand,@JsonKey(name: 'publish_date') DateTime publishDate,@JsonKey(name: 'view_count') int viewCount
});




}
/// @nodoc
class _$NewsModelCopyWithImpl<$Res>
    implements $NewsModelCopyWith<$Res> {
  _$NewsModelCopyWithImpl(this._self, this._then);

  final NewsModel _self;
  final $Res Function(NewsModel) _then;

/// Create a copy of NewsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? category = null,Object? thumbnail = freezed,Object? summary = null,Object? content = null,Object? authorId = null,Object? expand = freezed,Object? publishDate = null,Object? viewCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,expand: freezed == expand ? _self.expand : expand // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,publishDate: null == publishDate ? _self.publishDate : publishDate // ignore: cast_nullable_to_non_nullable
as DateTime,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NewsModel].
extension NewsModelPatterns on NewsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewsModel value)  $default,){
final _that = this;
switch (_that) {
case _NewsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewsModel value)?  $default,){
final _that = this;
switch (_that) {
case _NewsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String category,  String? thumbnail,  String summary,  String content, @JsonKey(name: 'author')  String authorId, @JsonKey(name: 'expand')  Map<String, dynamic>? expand, @JsonKey(name: 'publish_date')  DateTime publishDate, @JsonKey(name: 'view_count')  int viewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewsModel() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.category,_that.thumbnail,_that.summary,_that.content,_that.authorId,_that.expand,_that.publishDate,_that.viewCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String category,  String? thumbnail,  String summary,  String content, @JsonKey(name: 'author')  String authorId, @JsonKey(name: 'expand')  Map<String, dynamic>? expand, @JsonKey(name: 'publish_date')  DateTime publishDate, @JsonKey(name: 'view_count')  int viewCount)  $default,) {final _that = this;
switch (_that) {
case _NewsModel():
return $default(_that.id,_that.title,_that.slug,_that.category,_that.thumbnail,_that.summary,_that.content,_that.authorId,_that.expand,_that.publishDate,_that.viewCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String slug,  String category,  String? thumbnail,  String summary,  String content, @JsonKey(name: 'author')  String authorId, @JsonKey(name: 'expand')  Map<String, dynamic>? expand, @JsonKey(name: 'publish_date')  DateTime publishDate, @JsonKey(name: 'view_count')  int viewCount)?  $default,) {final _that = this;
switch (_that) {
case _NewsModel() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.category,_that.thumbnail,_that.summary,_that.content,_that.authorId,_that.expand,_that.publishDate,_that.viewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NewsModel extends NewsModel {
  const _NewsModel({required this.id, required this.title, required this.slug, required this.category, this.thumbnail, required this.summary, required this.content, @JsonKey(name: 'author') required this.authorId, @JsonKey(name: 'expand') final  Map<String, dynamic>? expand, @JsonKey(name: 'publish_date') required this.publishDate, @JsonKey(name: 'view_count') this.viewCount = 0}): _expand = expand,super._();
  factory _NewsModel.fromJson(Map<String, dynamic> json) => _$NewsModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String slug;
@override final  String category;
@override final  String? thumbnail;
@override final  String summary;
@override final  String content;
@override@JsonKey(name: 'author') final  String authorId;
 final  Map<String, dynamic>? _expand;
@override@JsonKey(name: 'expand') Map<String, dynamic>? get expand {
  final value = _expand;
  if (value == null) return null;
  if (_expand is EqualUnmodifiableMapView) return _expand;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'publish_date') final  DateTime publishDate;
@override@JsonKey(name: 'view_count') final  int viewCount;

/// Create a copy of NewsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewsModelCopyWith<_NewsModel> get copyWith => __$NewsModelCopyWithImpl<_NewsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.category, category) || other.category == category)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.content, content) || other.content == content)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&const DeepCollectionEquality().equals(other._expand, _expand)&&(identical(other.publishDate, publishDate) || other.publishDate == publishDate)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,category,thumbnail,summary,content,authorId,const DeepCollectionEquality().hash(_expand),publishDate,viewCount);

@override
String toString() {
  return 'NewsModel(id: $id, title: $title, slug: $slug, category: $category, thumbnail: $thumbnail, summary: $summary, content: $content, authorId: $authorId, expand: $expand, publishDate: $publishDate, viewCount: $viewCount)';
}


}

/// @nodoc
abstract mixin class _$NewsModelCopyWith<$Res> implements $NewsModelCopyWith<$Res> {
  factory _$NewsModelCopyWith(_NewsModel value, $Res Function(_NewsModel) _then) = __$NewsModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String slug, String category, String? thumbnail, String summary, String content,@JsonKey(name: 'author') String authorId,@JsonKey(name: 'expand') Map<String, dynamic>? expand,@JsonKey(name: 'publish_date') DateTime publishDate,@JsonKey(name: 'view_count') int viewCount
});




}
/// @nodoc
class __$NewsModelCopyWithImpl<$Res>
    implements _$NewsModelCopyWith<$Res> {
  __$NewsModelCopyWithImpl(this._self, this._then);

  final _NewsModel _self;
  final $Res Function(_NewsModel) _then;

/// Create a copy of NewsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? category = null,Object? thumbnail = freezed,Object? summary = null,Object? content = null,Object? authorId = null,Object? expand = freezed,Object? publishDate = null,Object? viewCount = null,}) {
  return _then(_NewsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,expand: freezed == expand ? _self._expand : expand // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,publishDate: null == publishDate ? _self.publishDate : publishDate // ignore: cast_nullable_to_non_nullable
as DateTime,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
