import 'dart:convert';
import 'dart:io';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/api_endpoint.dart';
import 'package:borderless/model/chat_list.dart';
import 'package:borderless/model/chat_history.dart';
import 'package:borderless/model/friend_request.dart';
import 'package:borderless/model/post_comment.dart';
import 'package:borderless/model/posts.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/utils/is_loading.dart';
import 'package:borderless/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {

  static String? authToken = AuthManager.getAuthToken();
  // all posts
  static Future<List<Post>> fetchPosts() async {

    String apiUrl = '${ApiEndpoint.endpoint}/api/posts';
    final response = await http.get(
      Uri.parse(apiUrl), 
      headers: {'Authorization': 'Bearer $authToken'}, 
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      return responseData.map((data) => Post.fromJson(data)).toList();
    } else {
      // Handle other HTTP error codes
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }
  // loggedin user posts
  static Future<List<Post>> fetchLoggedInUserPosts() async {

    final url = Uri.parse('${ApiEndpoint.endpoint}/api/posts/login/user');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken', // Include the authentication token
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
      return responseData.map((data) => Post.fromJson(data)).toList();
    } else {
      // If the server returns an error response, throw an exception
    throw Exception('Failed to fetch logged-in user posts');
    }
  }

  // search friends
  static Future<List<UserProfile>> searchUser(String query) async {

    final url = Uri.parse('${ApiEndpoint.endpoint}/api/users/search/?query=$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));

        final List<UserProfile> searchResults = jsonData.map((data) => UserProfile.fromJson(data)).toList();
        return searchResults;
 
      } else {
        throw Exception('Failed to search users');
      }
    } catch (e) {
      rethrow;
    }
  }

  // send friend request
  static Future<void> addFriend(context, String userId) async {

    final url = Uri.parse('${ApiEndpoint.endpoint}/send/friend/request/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'receiver': userId}),
      );
      if (response.statusCode == 201) {
        // Friend request sent successfully
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已發送朋友邀請')),
          );
        }
      } else {
        throw ('無法發送請求，請稍候再試');
      }
    } catch (e) {
      rethrow;
    }
  }

  // cancel friend request
  static Future<void> cancelFriendRequest(String userId) async {
    try {
      final url = Uri.parse('${ApiEndpoint.endpoint}/cancel/friend/request/');

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'receiver_id': userId}),
      );

    } catch (e) {
      rethrow;
    }
  }

  // accept friend request
  static Future<void> acceptFriendRequest(context,String userId) async {
    try {
      final url = Uri.parse("${ApiEndpoint.endpoint}/accept/friend/request/");

      final resposne = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'sender': userId}),
      );
      if (resposne.statusCode == 200) {
        if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: "添加好友成功", 
          backgroundColor: Colors.green,
        );
      }
      }
    } catch (e) {
      rethrow;
    }

    
  }

  // get friend list
  static Future<List<UserProfile>> getFriendList() async {
    final url = Uri.parse("${ApiEndpoint.endpoint}/api/user/friends/");

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $authToken'}, 
    );

    if (response.statusCode == 200) {
       final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes))['friends'] as List<dynamic>;
      // Parse the list of friends from the response data
      final List<UserProfile> friends = responseData.map((data) => UserProfile.fromJson(data)).toList();
      return friends;
    } else {
      throw Exception();
    }

  }

  // static UserProfile? _cachedUserProfile;
  // current login user
  static Future<UserProfile> getCurrentUserProfile() async {

    final url = Uri.parse('${ApiEndpoint.endpoint}/current/user/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final userProfile = UserProfile.fromJson(jsonData);

      // Cache the fetched user data
      // _cachedUserProfile = UserProfile;

      return userProfile;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // create post
  static Future<void> uploadPost(context,String authToken, String caption, List<XFile> images, File video) async {

    if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IsLoading(),
            ),
          );
        }
    // Create a multipart request

    final request = http.MultipartRequest('POST', Uri.parse('${ApiEndpoint.endpoint}/api/posts'));
    
    // Set authorization header
    request.headers['Authorization'] = 'Bearer $authToken';
    
    // Add caption field
    request.fields['post_content'] = caption;

    // Add image files
    for (int i = 0; i < images.length; i++) {
      request.files.add(await http.MultipartFile.fromPath('post_images', images[i].path));
    }

    // add video files

    request.files.add(await http.MultipartFile.fromPath(
        'post_video',
        video.path,
    ));


    // Send the request
    final response = await request.send();

    try {
        // Check the response status 201 created 
      if (response.statusCode == 201) {
        // loading screen
        if (context.mounted) {
          CustomSnackbar.show(
          context: context, 
          message: "創建成功了🦆!!!", 
          backgroundColor: Colors.green,
        );
        }

        if (context.mounted) {
          Navigator.of(context).pop();
        }
    
      } else {
        if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: "無法創建貼文喔, 再試試吧", 
          backgroundColor: Colors.red,
        );
      }

      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: "$e", 
          backgroundColor: Colors.red,
        );
      }
    }
    
  }
  // delete a post
  // delete response code 204
  static Future<void> deletePost(context, String pk) async {
   try {
    final url = Uri.parse('${ApiEndpoint.endpoint}/api/posts/$pk');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 204) {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: "刪除成功", 
          backgroundColor: Colors.green,
        );
      }
    } else {
      // Handle other status codes (e.g., 404 Not Found)
      if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: "你要小心了...", 
          backgroundColor: Colors.red,
        );
      }
      
    }
  } catch (e) {
    // Handle network errors or exceptions
    if (context.mounted) {
      CustomSnackbar.show(
          context: context, 
          message: "可能服務器有問題喔。。。", 
          backgroundColor: Colors.red,
        );
    }
    
  }
  }

  // register new account
  static Future register({
    required String username,
    required String email,
    required String password,
    File? image,
  }) async {
    String endpoint = "${ApiEndpoint.endpoint}/user/register/";

    var request = http.MultipartRequest('POST', Uri.parse(endpoint));
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;

    if (image != null) {
      // String fileName = image.path.split("/").last;
      request.files.add( await http.MultipartFile.fromPath('avatar', image.path));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      // Registration successful
      return true;
    } else {
      // Registration failed
      throw Exception('Failed to register user');
    }
  }

  // get friends requests
  static Future<List<FriendRequest>> fetchFriendRequests() async {
    String url = "${ApiEndpoint.endpoint}/api/user/friend/request/";

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $authToken'}, 
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => FriendRequest.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load friend requests');
    }
  }
  
  // fetch chat history
  static Future<List<ChatMessage>> getUserTextChatHistory(String userId) async {
    final url = Uri.parse('${ApiEndpoint.endpoint}/api/chat/history/$userId/');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'}, 
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (error) {
      throw Exception('Failed to connect to server: $error');
    }
  }

  static Future<List<ImageMessage>> getUserImageChatHistory(String userId) async {
    final url = Uri.parse('${ApiEndpoint.endpoint}/api/chat/history/images/$userId/');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'}, 
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData.map((json) => ImageMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (error) {
      throw Exception('Failed to connect to server: $error');
    }
  }

  static Future<List<AudioMessage>> getUserAudioChatHistory(String userId) async {
    final url = Uri.parse('${ApiEndpoint.endpoint}/api/chat/history/voice/$userId/');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'}, 
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData.map((json) => AudioMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (error) {
      throw Exception('Failed to connect to server: $error');
    }
  }


  // update user profile
  static Future updateUserProfile({
    required context,
    required String username,
    required String email,
    required String bio,
    File? image,
  }) async {
    final String endpoint = '${ApiEndpoint.endpoint}/user/update/';
    try {
      var request = http.MultipartRequest(
        'PUT', Uri.parse(endpoint),
      );
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['bio'] = bio; 

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', image.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // User data updated successfully
        CustomSnackbar.show(
          context: context, 
          message: '更新成功， 哈哈哈哈哈', 
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      // Handle exception
      throw Exception('Failed to update user data: $e');
    }
  }

  // get chat list
  static Future<List<ChatListModel>> getChatList() async {
    final String url = '${ApiEndpoint.endpoint}/api/chatlists/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'}, 
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => ChatListModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load chat');
      }      
    } catch (e) {
      rethrow;
    }

  }

  // get comments data
  static Future<List<PostCommentModel>> getPostComments(String postId) async {
    final String url = '${ApiEndpoint.endpoint}/api/post/comments/$postId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'}, 
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => PostCommentModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load comments');
      }      
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Post>> getCheckUserPosts(String userId) async {
    final String url = '${ApiEndpoint.endpoint}/api/check/user/posts/$userId';

    final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'}, 
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Post.fromJson(item)).toList();
    } else {
    // Handle the case when the response status code is not 200
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }

  }
  
  static Future<void> sendImageMessage(context, String userId, XFile? image) async {

    final url = Uri.parse('${ApiEndpoint.endpoint}/api/chat/images/');
    final request = http.MultipartRequest('POST', url);

    // Set authorization header
    request.headers['Authorization'] = 'Bearer $authToken';
    
    // Add userId field
    request.fields['receiver'] = userId;

    // Add image files
    // for (int i = 0; i < images.length; i++) {
    //   request.files.add(await http.MultipartFile.fromPath('post_images', images[i].path));
    // }
    request.files.add(await http.MultipartFile.fromPath('images', image!.path));

    // Send the request
    final response = await request.send();

    try {
        // Check the response status 201 created 
      if (response.statusCode == 201) {
        // loading screen
        return;
    
      } else {
        Fluttertoast.showToast(
        msg: "無法發送圖片",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
      }

    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: "$e", 
          backgroundColor: Colors.red,
        );
      }
    }

  }


}
