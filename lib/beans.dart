import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripbuddyapp/utils.dart';

/**
 *  @author Pradeep CH
 */
class Group {
  String groupId;
  String passCode;
  int createdOn;
  String addedDateFormatted;
  String status;
  String createdBy;
  String createdByDisplayName;
  int lastUpdatedOn;
  bool passCodeRequired;
  bool isPrivate;

  Group load(Map<String, dynamic> attributes) {
    this.groupId = attributes['groupId'];
    this.passCode = attributes['passcode'];
    this.status = attributes['status'];
    this.createdOn = attributes['createdOn'];
    this.createdBy = attributes['createdBy'];
    this.createdByDisplayName = attributes['createdByDisplayName'];
    this.lastUpdatedOn = attributes['lastUpdatedOn'];
    this.isPrivate = attributes['isPrivate'];
    this.passCodeRequired = attributes['passCodeRequired'];
    this.addedDateFormatted = CommonUtil.formatDate(this.createdOn);
    return this;
  }

  @override
  String toString() {
    return "[GroupId: $groupId, Passcode: $passCode]";
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = Map();
    attributes['groupId'] = this.groupId;
    attributes['passcode'] = this.passCodeRequired ? this.passCode : "";
    attributes['passCodeRequired'] =
        this.passCodeRequired == null ? false : this.passCodeRequired;
    attributes['isPrivate'] = this.isPrivate == null ? false : this.isPrivate;
    if (this.status != null) attributes['status'] = this.status;
    if (this.createdOn != null) attributes['createdOn'] = this.createdOn;
    if (this.createdBy != null) attributes['createdBy'] = this.createdBy;
    if (this.createdBy != null)
      attributes['createdByDisplayName'] = this.createdBy;
    if (this.lastUpdatedOn != null)
      attributes['lastUpdatedOn'] = this.lastUpdatedOn;

    return attributes;
  }
}

class GroupMember {
  String uid;
  String displayName;
  LatLng location;
  int lastUpdated;
  bool isMaster;
  String id;
  String photoURL;

  GroupMember loadInfo(Map<String, dynamic> attributes) {
    uid = attributes['uid'];
    displayName = attributes['displayName'];
    lastUpdated = attributes['lastUpdated'];
    location = getAsLocation(attributes['location']);
    isMaster = attributes['isMaster'];
    id = attributes['id'];
    photoURL = attributes['photoURL'];
    return this;
  }

  @override
  String toString() {
    return "[uid:$uid, displayName: $displayName, location :$location, lastupdated: $lastUpdated]";
  }

  LatLng getAsLocation(dynamic attribut) {
    if (attribut == null) return null;
    if (attribut is GeoPoint)
      return LatLng(attribut.latitude, attribut.longitude);
    return null;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = Map();
    attributes['uid'] = uid;
    if (displayName != null) attributes['displayName'] = displayName;
    if (lastUpdated != null) attributes['lastUpdated'] = lastUpdated;
    if (location != null)
      attributes['location'] = GeoPoint(location.latitude, location.longitude);

    if (photoURL != null) attributes['photoURL'] = photoURL;
    if (isMaster != null) attributes['isMaster'] = isMaster;
    if (id != null) attributes['id'] = id;
    return attributes;
  }
}
