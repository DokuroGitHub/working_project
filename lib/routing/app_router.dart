import 'package:flutter/material.dart';
import 'package:working_project/app/home/account/account_page.dart';
import 'package:working_project/app/home/admin/my_users/my_user_details_page.dart';
import 'package:working_project/app/home/admin/post_reports/post_reported_details_page.dart';
import 'package:working_project/app/home/member/posts/post_details_page.dart';
import 'package:working_project/app/home/member/shipments/edit_shipment/edit_shipment_page.dart';
import 'package:working_project/common_widgets/full_file_view_page.dart';
import 'package:working_project/models/attachment.dart';
import 'package:working_project/models/post_reported.dart';
import 'package:working_project/models/shipment.dart';
import '/app/home/feedbacks/feedbacks_page.dart';
import '/app/home/member/posts/edit_post_page.dart';
import '/app/home/member/shipments/shipment_details/shipment_details_page.dart';
import '/app/home/messages/messages_page.dart';
import '/app/sign_in/email_password_sign_in/email_password_sign_in_page.dart';
import '/app/sign_in/sign_in_page.dart';
import '/models/my_user.dart';
import '/models/post.dart';

class AppRoutes {
  static const signInPage = '/sign-in-page';
  static const emailPasswordSignInPage = '/email-password-sign-in-page';
  static const finishMyUserInfoPage = '/finish-my-user-info-page';
  static const editPostPage = '/edit-post-page';
  static const messagesPage = '/messages-page';
  static const shipmentDetailsPage = '/shipment-details-page';
  static const editShipmentPage = '/edit-shipment-page';
  static const feedbacksPage = '/feedbacks-page';
  static const accountPage = '/account-page';
  static const fullFileViewPage = '/full-file-view-page';
  static const postDetailsPage = '/post-details-page';

  //TODO: admin pages
  static const myUserDetailsPage = '/my-user-details-page';
  static const postReportDetailsPage = '/post-report-details-page';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.signInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => SignInPage(),
          settings: settings,
          fullscreenDialog: true,
        );
      //TODO: EmailPasswordSignInPage.withFirebaseAuth(void)
      case AppRoutes.emailPasswordSignInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(
              onSignedIn: args as void Function()),
          settings: settings,
          fullscreenDialog: true,
        );
      //TODO: EditPostPage(myUser: myUser, post: post)
      case AppRoutes.editPostPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final post = mapArgs['post'] as Post?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditPostPage(myUser: myUser, post: post),
          settings: settings,
          fullscreenDialog: true,
        );
      //TODO:  MessagesPage(myUser: myUser, conversationId: conversationId)
      case AppRoutes.messagesPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final conversationId = mapArgs['conversationId'] as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              MessagesPage(myUser: myUser, conversationId: conversationId),
          settings: settings,
          fullscreenDialog: true,
        );
      //TODO:  ShipmentDetailsPage(myUser: myUser, shipmentId: shipmentId)
      case AppRoutes.shipmentDetailsPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final shipmentId = mapArgs['shipmentId'] as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              ShipmentDetailsPage(myUser: myUser, shipmentId: shipmentId),
          settings: settings,
          fullscreenDialog: true,
        );
    //TODO:  ShipmentDetailsPage(myUser: myUser, shipmentId: shipmentId)
      case AppRoutes.editShipmentPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final shipment = mapArgs['shipment'] as Shipment?;
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              EditShipmentPage(myUser: myUser, shipment: shipment),
          settings: settings,
          fullscreenDialog: true,
        );
      //TODO: feedbacksPage
      case AppRoutes.feedbacksPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final myUserId2 = mapArgs['myUserId2'] as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FeedBacksPage(myUser: myUser, myUserId2: myUserId2),
          settings: settings,
          fullscreenDialog: true,
        );
    //TODO: accountPage
      case AppRoutes.accountPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final myUserId2 = mapArgs['myUserId2'] as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) => AccountPage(myUser: myUser, myUserId2: myUserId2),
          settings: settings,
          fullscreenDialog: true,
        );
    //TODO: fullPhotoPage
      case AppRoutes.fullFileViewPage:
        final mapArgs = args as Map<String, dynamic>;
        final attachment = mapArgs['attachment'] as Attachment;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FullFileViewPage(attachment: attachment),
          settings: settings,
          fullscreenDialog: true,
        );
    //TODO: postReportDetailsPage
      case AppRoutes.postReportDetailsPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final postReported = mapArgs['postReported'] as PostReported;
        return MaterialPageRoute<dynamic>(
          builder: (_) => PostReportedDetailsPage(myUser: myUser, postReported: postReported),
          settings: settings,
          fullscreenDialog: true,
        );
    //TODO: postReportDetailsPage
      case AppRoutes.myUserDetailsPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final myUserId2 = mapArgs['myUserId2'] as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) => MyUserDetailsPage(myUser: myUser, myUserId2: myUserId2),
          settings: settings,
          fullscreenDialog: true,
        );
    //TODO: postReportDetailsPage
      case AppRoutes.postDetailsPage:
        final mapArgs = args as Map<String, dynamic>;
        final myUser = mapArgs['myUser'] as MyUser;
        final postId = mapArgs['postId'] as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) => PostDetailsPage(myUser: myUser, postId: postId),
          settings: settings,
          fullscreenDialog: true,
        );
      //TODO: default
      default:
        // TODO: Throw
        return null;
    }
  }
}
