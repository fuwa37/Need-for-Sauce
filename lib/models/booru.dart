part of models;

class DanbooruObject {
  DanbooruObject({
    this.id,
    this.createdAt,
    this.uploaderId,
    this.score,
    this.source,
    this.md5,
    this.lastCommentBumpedAt,
    this.rating,
    this.imageWidth,
    this.imageHeight,
    this.tagString,
    this.isNoteLocked,
    this.favCount,
    this.fileExt,
    this.lastNotedAt,
    this.isRatingLocked,
    this.parentId,
    this.hasChildren,
    this.approverId,
    this.tagCountGeneral,
    this.tagCountArtist,
    this.tagCountCharacter,
    this.tagCountCopyright,
    this.fileSize,
    this.isStatusLocked,
    this.poolString,
    this.upScore,
    this.downScore,
    this.isPending,
    this.isFlagged,
    this.isDeleted,
    this.tagCount,
    this.updatedAt,
    this.isBanned,
    this.pixivId,
    this.lastCommentedAt,
    this.hasActiveChildren,
    this.bitFlags,
    this.tagCountMeta,
    this.hasLarge,
    this.hasVisibleChildren,
    this.isFavorited,
    this.tagStringGeneral,
    this.tagStringCharacter,
    this.tagStringCopyright,
    this.tagStringArtist,
    this.tagStringMeta,
    this.fileUrl,
    this.largeFileUrl,
    this.previewFileUrl,
  });

  int id;
  DateTime createdAt;
  int uploaderId;
  int score;
  String source;
  String md5;
  DateTime lastCommentBumpedAt;
  String rating;
  int imageWidth;
  int imageHeight;
  String tagString;
  bool isNoteLocked;
  int favCount;
  String fileExt;
  DateTime lastNotedAt;
  bool isRatingLocked;
  int parentId;
  bool hasChildren;
  int approverId;
  int tagCountGeneral;
  int tagCountArtist;
  int tagCountCharacter;
  int tagCountCopyright;
  int fileSize;
  bool isStatusLocked;
  String poolString;
  int upScore;
  int downScore;
  bool isPending;
  bool isFlagged;
  bool isDeleted;
  int tagCount;
  DateTime updatedAt;
  bool isBanned;
  int pixivId;
  DateTime lastCommentedAt;
  bool hasActiveChildren;
  int bitFlags;
  int tagCountMeta;
  bool hasLarge;
  bool hasVisibleChildren;
  bool isFavorited;
  String tagStringGeneral;
  String tagStringCharacter;
  String tagStringCopyright;
  String tagStringArtist;
  String tagStringMeta;
  String fileUrl;
  String largeFileUrl;
  String previewFileUrl;

  factory DanbooruObject.fromJson(Map<String, dynamic> json) => DanbooruObject(
        id: json["id"],
        createdAt: (json["created_at"] == null)
            ? null
            : DateTime.parse(json["created_at"]),
        uploaderId: json["uploader_id"],
        score: json["score"],
        source: json["source"],
        md5: json["md5"],
        lastCommentBumpedAt: (json["last_comment_bumped_at"] == null)
            ? null
            : DateTime.parse(json["last_comment_bumped_at"]),
        rating: json["rating"],
        imageWidth: json["image_width"],
        imageHeight: json["image_height"],
        tagString: json["tag_string"],
        isNoteLocked: json["is_note_locked"],
        favCount: json["fav_count"],
        fileExt: json["file_ext"],
        lastNotedAt: (json["last_noted_at"] == null)
            ? null
            : DateTime.parse(json["last_noted_at"]),
        isRatingLocked: json["is_rating_locked"],
        parentId: json["parent_id"],
        hasChildren: json["has_children"],
        approverId: json["approver_id"],
        tagCountGeneral: json["tag_count_general"],
        tagCountArtist: json["tag_count_artist"],
        tagCountCharacter: json["tag_count_character"],
        tagCountCopyright: json["tag_count_copyright"],
        fileSize: json["file_size"],
        isStatusLocked: json["is_status_locked"],
        poolString: json["pool_string"],
        upScore: json["up_score"],
        downScore: json["down_score"],
        isPending: json["is_pending"],
        isFlagged: json["is_flagged"],
        isDeleted: json["is_deleted"],
        tagCount: json["tag_count"],
        updatedAt: (json["updated_at"] == null)
            ? null
            : DateTime.parse(json["updated_at"]),
        isBanned: json["is_banned"],
        pixivId: json["pixiv_id"],
        lastCommentedAt: (json["last_commented_at"] == null)
            ? null
            : DateTime.parse(json["last_commented_at"]),
        hasActiveChildren: json["has_active_children"],
        bitFlags: json["bit_flags"],
        tagCountMeta: json["tag_count_meta"],
        hasLarge: json["has_large"],
        hasVisibleChildren: json["has_visible_children"],
        isFavorited: json["is_favorited"],
        tagStringGeneral: json["tag_string_general"],
        tagStringCharacter: json["tag_string_character"],
        tagStringCopyright: json["tag_string_copyright"],
        tagStringArtist: json["tag_string_artist"],
        tagStringMeta: json["tag_string_meta"],
        fileUrl: json["file_url"],
        largeFileUrl: json["large_file_url"],
        previewFileUrl: json["preview_file_url"],
      );

  static Future<DanbooruObject> getInfo(int danbooruId) async {
    var response;
    try {
      response = await Sauce.booru('danbooru', danbooruId.toString()).get('');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No post with id $danbooruId found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            throw NoInfoException("Couldn't connect to internet");
          }
      }
    }
    if (response == null) return null;

    return DanbooruObject.fromJson(response.data);
  }
}

class GelbooruObject {
  GelbooruObject({
    this.source,
    this.directory,
    this.hash,
    this.height,
    this.id,
    this.image,
    this.change,
    this.owner,
    this.parentId,
    this.rating,
    this.sample,
    this.sampleHeight,
    this.sampleWidth,
    this.score,
    this.tags,
    this.width,
    this.fileUrl,
    this.createdAt,
  });

  String source;
  String directory;
  String hash;
  int height;
  int id;
  String image;
  int change;
  String owner;
  int parentId;
  String rating;
  int sample;
  int sampleHeight;
  int sampleWidth;
  int score;
  String tags;
  int width;
  String fileUrl;
  String createdAt;

  factory GelbooruObject.fromJson(Map<String, dynamic> json) => GelbooruObject(
        source: json["source"],
        directory: json["directory"],
        hash: json["hash"],
        height: json["height"],
        id: json["id"],
        image: json["image"],
        change: json["change"],
        owner: json["owner"],
        parentId: json["parent_id"],
        rating: json["rating"],
        sample: json["sample"],
        sampleHeight: json["sample_height"],
        sampleWidth: json["sample_width"],
        score: json["score"],
        tags: json["tags"],
        width: json["width"],
        fileUrl: json["file_url"],
        createdAt: json["created_at"],
      );

  static Future<GelbooruObject> getInfo(int gelbooruId) async {
    var response;
    try {
      response = await Sauce.booru('gelbooru', gelbooruId.toString()).get('');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No post with id $gelbooruId found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            throw NoInfoException("Couldn't connect to internet");
          }
      }
    }
    if (response?.data[0] == null) return null;

    return GelbooruObject.fromJson(response.data[0]);
  }
}

class YandereObject {
  YandereObject({
    this.id,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.creatorId,
    this.approverId,
    this.author,
    this.change,
    this.source,
    this.score,
    this.md5,
    this.fileSize,
    this.fileExt,
    this.fileUrl,
    this.isShownInIndex,
    this.previewUrl,
    this.previewWidth,
    this.previewHeight,
    this.actualPreviewWidth,
    this.actualPreviewHeight,
    this.sampleUrl,
    this.sampleWidth,
    this.sampleHeight,
    this.sampleFileSize,
    this.jpegUrl,
    this.jpegWidth,
    this.jpegHeight,
    this.jpegFileSize,
    this.rating,
    this.isRatingLocked,
    this.hasChildren,
    this.parentId,
    this.status,
    this.isPending,
    this.width,
    this.height,
    this.isHeld,
    this.framesPendingString,
    this.framesPending,
    this.framesString,
    this.frames,
    this.isNoteLocked,
    this.lastNotedAt,
    this.lastCommentedAt,
  });

  int id;
  String tags;
  int createdAt;
  int updatedAt;
  int creatorId;
  int approverId;
  String author;
  int change;
  String source;
  int score;
  String md5;
  int fileSize;
  String fileExt;
  String fileUrl;
  bool isShownInIndex;
  String previewUrl;
  int previewWidth;
  int previewHeight;
  int actualPreviewWidth;
  int actualPreviewHeight;
  String sampleUrl;
  int sampleWidth;
  int sampleHeight;
  int sampleFileSize;
  String jpegUrl;
  int jpegWidth;
  int jpegHeight;
  int jpegFileSize;
  String rating;
  bool isRatingLocked;
  bool hasChildren;
  int parentId;
  String status;
  bool isPending;
  int width;
  int height;
  bool isHeld;
  String framesPendingString;
  List<dynamic> framesPending;
  String framesString;
  List<dynamic> frames;
  bool isNoteLocked;
  int lastNotedAt;
  int lastCommentedAt;

  factory YandereObject.fromJson(Map<String, dynamic> json) => YandereObject(
        id: json["id"],
        tags: json["tags"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        creatorId: json["creator_id"],
        approverId: json["approver_id"],
        author: json["author"],
        change: json["change"],
        source: json["source"],
        score: json["score"],
        md5: json["md5"],
        fileSize: json["file_size"],
        fileExt: json["file_ext"],
        fileUrl: json["file_url"],
        isShownInIndex: json["is_shown_in_index"],
        previewUrl: json["preview_url"],
        previewWidth: json["preview_width"],
        previewHeight: json["preview_height"],
        actualPreviewWidth: json["actual_preview_width"],
        actualPreviewHeight: json["actual_preview_height"],
        sampleUrl: json["sample_url"],
        sampleWidth: json["sample_width"],
        sampleHeight: json["sample_height"],
        sampleFileSize: json["sample_file_size"],
        jpegUrl: json["jpeg_url"],
        jpegWidth: json["jpeg_width"],
        jpegHeight: json["jpeg_height"],
        jpegFileSize: json["jpeg_file_size"],
        rating: json["rating"],
        isRatingLocked: json["is_rating_locked"],
        hasChildren: json["has_children"],
        parentId: json["parent_id"],
        status: json["status"],
        isPending: json["is_pending"],
        width: json["width"],
        height: json["height"],
        isHeld: json["is_held"],
        framesPendingString: json["frames_pending_string"],
        framesPending: (json["frames_pending"] == null)
            ? null
            : List<dynamic>.from(json["frames_pending"].map((x) => x)),
        framesString: json["frames_string"],
        frames: (json["frames"] == null)
            ? null
            : List<dynamic>.from(json["frames"].map((x) => x)),
        isNoteLocked: json["is_note_locked"],
        lastNotedAt: json["last_noted_at"],
        lastCommentedAt: json["last_commented_at"],
      );

  static Future<YandereObject> getInfo(int yandereId) async {
    var response;
    try {
      response = await Sauce.booru('yandere', yandereId.toString()).get('');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No post with id $yandereId found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            throw NoInfoException("Couldn't connect to internet");
          }
      }
    }
    if (response?.data[0] == null) return null;

    return YandereObject.fromJson(response.data[0]);
  }
}

class KonachanObject {
  KonachanObject({
    this.id,
    this.tags,
    this.createdAt,
    this.creatorId,
    this.author,
    this.change,
    this.source,
    this.score,
    this.md5,
    this.fileSize,
    this.fileUrl,
    this.isShownInIndex,
    this.previewUrl,
    this.previewWidth,
    this.previewHeight,
    this.actualPreviewWidth,
    this.actualPreviewHeight,
    this.sampleUrl,
    this.sampleWidth,
    this.sampleHeight,
    this.sampleFileSize,
    this.jpegUrl,
    this.jpegWidth,
    this.jpegHeight,
    this.jpegFileSize,
    this.rating,
    this.hasChildren,
    this.parentId,
    this.status,
    this.width,
    this.height,
    this.isHeld,
    this.framesPendingString,
    this.framesPending,
    this.framesString,
    this.frames,
  });

  int id;
  String tags;
  int createdAt;
  int creatorId;
  String author;
  int change;
  String source;
  int score;
  String md5;
  int fileSize;
  String fileUrl;
  bool isShownInIndex;
  String previewUrl;
  int previewWidth;
  int previewHeight;
  int actualPreviewWidth;
  int actualPreviewHeight;
  String sampleUrl;
  int sampleWidth;
  int sampleHeight;
  int sampleFileSize;
  String jpegUrl;
  int jpegWidth;
  int jpegHeight;
  int jpegFileSize;
  String rating;
  bool hasChildren;
  dynamic parentId;
  String status;
  int width;
  int height;
  bool isHeld;
  String framesPendingString;
  List<dynamic> framesPending;
  String framesString;
  List<dynamic> frames;

  factory KonachanObject.fromJson(Map<String, dynamic> json) => KonachanObject(
        id: json["id"],
        tags: json["tags"],
        createdAt: json["created_at"],
        creatorId: json["creator_id"],
        author: json["author"],
        change: json["change"],
        source: json["source"],
        score: json["score"],
        md5: json["md5"],
        fileSize: json["file_size"],
        fileUrl: json["file_url"],
        isShownInIndex: json["is_shown_in_index"],
        previewUrl: json["preview_url"],
        previewWidth: json["preview_width"],
        previewHeight: json["preview_height"],
        actualPreviewWidth: json["actual_preview_width"],
        actualPreviewHeight: json["actual_preview_height"],
        sampleUrl: json["sample_url"],
        sampleWidth: json["sample_width"],
        sampleHeight: json["sample_height"],
        sampleFileSize: json["sample_file_size"],
        jpegUrl: json["jpeg_url"],
        jpegWidth: json["jpeg_width"],
        jpegHeight: json["jpeg_height"],
        jpegFileSize: json["jpeg_file_size"],
        rating: json["rating"],
        hasChildren: json["has_children"],
        parentId: json["parent_id"],
        status: json["status"],
        width: json["width"],
        height: json["height"],
        isHeld: json["is_held"],
        framesPendingString: json["frames_pending_string"],
        framesPending: (json["frames_pending"] == null)
            ? null
            : List<dynamic>.from(json["frames_pending"].map((x) => x)),
        framesString: json["frames_string"],
        frames: (json["frames"] == null)
            ? null
            : List<dynamic>.from(json["frames"].map((x) => x)),
      );

  static Future<KonachanObject> getInfo(int konachanId) async {
    var response;
    try {
      response = await Sauce.booru('konachan', konachanId.toString()).get('');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No post with id $konachanId found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            throw NoInfoException("Couldn't connect to internet");
          }
      }
    }
    if (response?.data[0] == null) return null;

    return KonachanObject.fromJson(response.data[0]);
  }
}

class E621Object {
  E621Object({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.file,
    this.preview,
    this.sample,
    this.score,
    this.tags,
    this.lockedTags,
    this.changeSeq,
    this.flags,
    this.rating,
    this.favCount,
    this.sources,
    this.pools,
    this.relationships,
    this.approverId,
    this.uploaderId,
    this.description,
    this.commentCount,
    this.isFavorited,
    this.hasNotes,
  });

  int id;
  DateTime createdAt;
  DateTime updatedAt;
  E621File file;
  E621File preview;
  E621File sample;
  E621Score score;
  List<String> tags;
  List<String> lockedTags;
  int changeSeq;
  E621Flags flags;
  String rating;
  int favCount;
  List<String> sources;
  List<int> pools;
  E621Relationships relationships;
  int approverId;
  int uploaderId;
  String description;
  int commentCount;
  bool isFavorited;
  bool hasNotes;

  factory E621Object.fromJson(Map<String, dynamic> json) {
    List<String> tags;

    if (json["tags"] != null) {
      tags = E621Tags.fromJson(json["tags"]).combineTags();
    }

    return E621Object(
      id: json["id"],
      createdAt: (json["created_at"] == null)
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: (json["updated_at"] == null)
          ? null
          : DateTime.parse(json["updated_at"]),
      file: (json["file"] == null) ? null : E621File.fromJson(json["file"]),
      preview:
          (json["preview"] == null) ? null : E621File.fromJson(json["preview"]),
      sample:
          (json["sample"] == null) ? null : E621File.fromJson(json["sample"]),
      score: (json["score"] == null) ? null : E621Score.fromJson(json["score"]),
      tags: tags,
      lockedTags: (json["locked_tags"] == null)
          ? null
          : List<String>.from(json["locked_tags"].map((x) => x)),
      changeSeq: json["change_seq"],
      flags: (json["flags"] == null) ? null : E621Flags.fromJson(json["flags"]),
      rating: json["rating"],
      favCount: json["fav_count"],
      sources: (json["sources"] == null)
          ? null
          : List<String>.from(json["sources"].map((x) => x)),
      pools: (json["pools"] == null)
          ? null
          : List<int>.from(json["pools"].map((x) => x)),
      relationships: (json["relationships"] == null)
          ? null
          : E621Relationships.fromJson(json["relationships"]),
      approverId: json["approver_id"],
      uploaderId: json["uploader_id"],
      description: json["description"],
      commentCount: json["comment_count"],
      isFavorited: json["is_favorited"],
      hasNotes: json["has_notes"],
    );
  }

  static Future<E621Object> getInfo(int e621Id) async {
    var response;
    try {
      response = await Sauce.booru('e621', e621Id.toString()).get('');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No post with id $e621Id found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            throw NoInfoException("Couldn't connect to internet");
          }
      }
    }
    if (response?.data['post'] == null) return null;

    return E621Object.fromJson(response.data['post']);
  }
}

class E621File {
  E621File({
    this.width,
    this.height,
    this.ext,
    this.size,
    this.md5,
    this.url,
  });

  int width;
  int height;
  String ext;
  int size;
  String md5;
  String url;

  factory E621File.fromJson(Map<String, dynamic> json) => E621File(
        width: json["width"],
        height: json["height"],
        ext: json["ext"],
        size: json["size"],
        md5: json["md5"],
        url: json["url"],
      );
}

class E621Flags {
  E621Flags({
    this.pending,
    this.flagged,
    this.noteLocked,
    this.statusLocked,
    this.ratingLocked,
    this.deleted,
  });

  bool pending;
  bool flagged;
  bool noteLocked;
  bool statusLocked;
  bool ratingLocked;
  bool deleted;

  factory E621Flags.fromJson(Map<String, dynamic> json) => E621Flags(
        pending: json["pending"],
        flagged: json["flagged"],
        noteLocked: json["note_locked"],
        statusLocked: json["status_locked"],
        ratingLocked: json["rating_locked"],
        deleted: json["deleted"],
      );
}

class E621Relationships {
  E621Relationships({
    this.parentId,
    this.hasChildren,
    this.hasActiveChildren,
    this.children,
  });

  int parentId;
  bool hasChildren;
  bool hasActiveChildren;
  List<int> children;

  factory E621Relationships.fromJson(Map<String, dynamic> json) =>
      E621Relationships(
        parentId: json["parent_id"],
        hasChildren: json["has_children"],
        hasActiveChildren: json["has_active_children"],
        children: (json["children"] == null)
            ? null
            : List<int>.from(json["children"].map((x) => x)),
      );
}

class E621Score {
  E621Score({
    this.up,
    this.down,
    this.total,
  });

  int up;
  int down;
  int total;

  factory E621Score.fromJson(Map<String, dynamic> json) => E621Score(
        up: json["up"],
        down: json["down"],
        total: json["total"],
      );
}

class E621Tags {
  E621Tags({
    this.general,
    this.species,
    this.character,
    this.copyright,
    this.artist,
    this.invalid,
    this.lore,
    this.meta,
  });

  List<String> general;
  List<String> species;
  List<String> character;
  List<String> copyright;
  List<String> artist;
  List<String> invalid;
  List<String> lore;
  List<String> meta;

  factory E621Tags.fromJson(Map<String, dynamic> json) => E621Tags(
        general: (json["general"] == null)
            ? []
            : List<String>.from(json["general"].map((x) => x)),
        species: (json["species"] == null)
            ? []
            : List<String>.from(json["species"].map((x) => x)),
        character: (json["character"] == null)
            ? []
            : List<String>.from(json["character"].map((x) => x)),
        copyright: (json["copyright"] == null)
            ? []
            : List<String>.from(json["copyright"].map((x) => x)),
        artist: (json["artist"] == null)
            ? []
            : List<String>.from(json["artist"].map((x) => x)),
        invalid: (json["invalid"] == null)
            ? []
            : List<String>.from(json["invalid"].map((x) => x)),
        lore: (json["lore"] == null)
            ? []
            : List<String>.from(json["lore"].map((x) => x)),
        meta: (json["meta"] == null)
            ? []
            : List<String>.from(json["meta"].map((x) => x)),
      );

  List<String> combineTags() {
    return this.general +
        this.species +
        this.character +
        this.copyright +
        this.artist +
        this.invalid +
        this.lore +
        this.meta;
  }
}
