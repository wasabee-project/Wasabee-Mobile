import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wasabee/classutils/dialog.dart';
import 'package:wasabee/classutils/operation.dart';
import 'package:wasabee/location/locationhelper.dart';
import 'package:wasabee/network/responses/operationFullResponse.dart';
import 'package:wasabee/network/urlmanager.dart';
import 'package:wasabee/pages/linkspage/linkfiltermanager.dart';
import 'package:wasabee/pages/linkspage/linklistvm.dart';
import 'package:wasabee/pages/mappage/map.dart';
import 'package:wasabee/pages/settingspage/constants.dart';

class LinkUtils {
  static const DIVIDER_HEIGHT_DEFAULT = 25.0;
  static const DIVIDER_HEIGHT_SMALL = 10.0;
  static int getCountOfUnassigned(List<Link> linkList) {
    return getUnassignedList(linkList).length;
  }

  static List<Link> getUnassignedList(List<Link> linkList) {
    return linkList == null
        ? List<Link>()
        : linkList
            .where((i) => i.assignedTo?.isEmpty == true || i.assignedTo == null)
            .toList();
  }

  static int getCountOfMine(List<Link> linkList, String googleId) {
    return getMyList(linkList, googleId).length;
  }

  static List<Link> getMyList(List<Link> linkList, String googleId) {
    return linkList == null
        ? List<Link>()
        : linkList
            .where((i) =>
                i.assignedTo?.isNotEmpty == true && i.assignedTo == googleId)
            .toList();
  }

  static int getCountOfComplete(List<Link> linkList) {
    return getCompleteList(linkList).length;
  }

  static List<Link> getCompleteList(List<Link> linkList) {
    return linkList == null
        ? List<Link>()
        : linkList.where((i) => i.completed == true).toList();
  }

  static int getCountOfIncomplete(List<Link> linkList) {
    return getIncompleteList(linkList).length;
  }

  static List<Link> getIncompleteList(List<Link> linkList) {
    return linkList == null
        ? List<Link>()
        : linkList.where((i) => i.completed != true).toList();
  }

  static List<Link> getFilteredLinks(
      List<Link> linkList, LinkFilterType type, String googleId) {
    var returningList = List<Link>();
    switch (type) {
      case LinkFilterType.All:
        returningList = linkList;
        break;
      case LinkFilterType.Unassigned:
        returningList = getUnassignedList(linkList);
        break;
      case LinkFilterType.Mine:
        returningList = getMyList(linkList, googleId);
        break;
      case LinkFilterType.Complete:
        returningList = getCompleteList(linkList);
        break;
      case LinkFilterType.Incomplete:
        returningList = getIncompleteList(linkList);
        break;
    }
    return returningList;
  }

  static AlertDialog getLinkInfoAlert(
      BuildContext context,
      LinkListViewModel vm,
      String googleId,
      Operation operation,
      MapPageState mapPageState) {
    var fromPortal = OperationUtils.getPortalFromID(vm.fromPortalId, operation);
    var toPortal = OperationUtils.getPortalFromID(vm.toPortalId, operation);
    List<Widget> dialogWidgets = <Widget>[
      RaisedButton(
        color: Colors.green,
        child: Text(
          'View Link On Map',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          //mapPageState.makeZoomedPositionFromLatLng(vm.latLng);
          mapPageState.tabController.animateTo(0);
        },
      ),
    ];
    dialogWidgets
        .add(getPortalSection(fromPortal, true, mapPageState, context));
    dialogWidgets.add(getPortalSection(toPortal, false, mapPageState, context));
    // dialogWidgets.addAll(
    //     DialogUtils.getCompleteIncompleteButton(target, opId, context, mapPageState));
    if (vm.comment?.isNotEmpty == true)
      dialogWidgets.add(DialogUtils.getInfoAlertCommentWidget(vm.comment));

    if (vm.assignedNickname?.isNotEmpty == true && vm.assignedTo != googleId)
      dialogWidgets.add(DialogUtils.addAssignedToWidget(vm.assignedNickname));
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Link",
                textAlign: TextAlign.center,
              )),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.close),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          )
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: dialogWidgets,
        ),
      ),
    );
  }

  static Widget getPortalSection(Portal portal, bool isFromPortal,
      MapPageState mapPageState, BuildContext context) {
    var titleStringSegment = "To";
    if (isFromPortal) titleStringSegment = "From";
    return Card(
        color: WasabeeConstants.CARD_COLOR,
        child: Column(
          children: <Widget>[
            Divider(color: WasabeeConstants.CARD_COLOR),
            Text(
              '$titleStringSegment',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  color: WasabeeConstants.CARD_TEXT_COLOR),
            ),
            Text(
              '${portal.name}',
              style: TextStyle(color: WasabeeConstants.CARD_TEXT_COLOR),
            ),
            Divider(
              color: Colors.white,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              IconButton(
                  icon: Image.asset('assets/icons/icon_iitc.png'),
                  onPressed: () {
                    UrlManager.launchIntelUrl(portal.lat, portal.lng);
                  }),
              VerticalDivider(),
              IconButton(
                  icon: Icon(Icons.filter_center_focus, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    mapPageState.makeZoomedPositionFromLatLng(
                        LocationHelper.getPortalLoc(portal));
                    mapPageState.tabController.animateTo(0);
                  }),
              VerticalDivider(),
              IconButton(
                  icon: Icon(Icons.directions, color: Colors.white),
                  onPressed: () {
                    //TODO add navigate with map thing
                  })
            ]),
          ],
        ));
  }
}
