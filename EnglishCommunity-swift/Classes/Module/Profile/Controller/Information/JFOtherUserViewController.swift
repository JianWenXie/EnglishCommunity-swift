//
//  JFOtherUserViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/21.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit
import YYWebImage

class JFOtherUserViewController: UIViewController {

    /// 用户id
    var userId: Int = 0 {
        didSet {
            loadUserInfo(userId)
        }
    }
    
    /// 用户信息
    var userInfo: JFAccountModel? {
        didSet {
            guard let userInfo = userInfo else {
                return
            }
            
            avatarImageView.yy_setImageWithURL(NSURL(string: userInfo.avatar!), options: YYWebImageOptions.Progressive)
            nicknameButton.setTitle(userInfo.nickname!, forState: .Normal)
            followingLabel.text = "关注 \(userInfo.followingCount)"
            followersLabel.text = "粉丝 \(userInfo.followersCount)"
            sayLabel.text = "\"\(userInfo.say!)\""
            followButton.setTitle(userInfo.followed == 0 ? "关注" : "取消关注", forState: .Normal)
            if userInfo.id == JFAccountModel.shareAccount()?.id {
                followButton.hidden = true
            } else {
                followButton.hidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户中心"
        view.backgroundColor = COLOR_ALL_BG
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        view.addSubview(headerView)
        view.addSubview(avatarImageView)
        view.addSubview(nicknameButton)
        view.addSubview(followingLabel)
        view.addSubview(lineView)
        view.addSubview(followersLabel)
        view.addSubview(sayLabel)
        view.addSubview(followButton)
        
        headerView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(191)
        }
        
        avatarImageView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(headerView.snp_bottom)
            make.size.equalTo(CGSize(width: 83, height: 83))
        }
        
        nicknameButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(avatarImageView.snp_bottom).offset(15)
        }
        
        followingLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(view).offset(-40)
            make.top.equalTo(nicknameButton.snp_bottom).offset(15)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(followingLabel)
            make.size.equalTo(CGSize(width: 0.5, height: 10))
        }
        
        followersLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(view).offset(40)
            make.top.equalTo(nicknameButton.snp_bottom).offset(15)
        }
        
        sayLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(followingLabel.snp_bottom).offset(27)
            make.width.equalTo(SCREEN_WIDTH - 100)
        }
        
        followButton.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(49)
        }
        
    }
    
    /**
     加载用户信息
     
     - parameter userId: 用户id
     */
    private func loadUserInfo(userId: Int) {
        
        JFProgressHUD.show()
        JFAccountModel.getOtherUserInfo(userId) { (userInfo) in
            JFProgressHUD.dismiss()
            guard let userInfo = userInfo else {
                return
            }
            
            self.userInfo = userInfo
        }
    }
    
    /**
     点击了关注按钮
     */
    @objc private func didTappedFollowButton() {
        
        JFProgressHUD.show()
        JFNetworkTools.shareNetworkTool.addOrCancelFriend(userId, finished: { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                JFProgressHUD.dismiss()
                return
            }
            
            if result["result"]["type"].stringValue == "add" {
                self.followButton.setTitle("取消关注", forState: .Normal)
            } else {
                self.followButton.setTitle("关注", forState: .Normal)
            }
            
            JFAccountModel.getSelfUserInfo({ (success) in
                JFProgressHUD.showInfoWithStatus("操作成功")
            })
        })
    }
    
    // MARK: - 懒加载
    /// 头部视图
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_NAV_BG
        return view
    }()
    
    /// 头像
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 41.5
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = COLOR_ALL_BG.CGColor
        imageView.layer.borderWidth = 3
        return imageView
    }()
    
    /// 昵称
    private lazy var nicknameButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitleColor(UIColor.colorWithHexString("444444"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(18)
        return button
    }()
    
    /// 粉丝
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.colorWithHexString("7b9cac")
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    /// 竖线
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("7b9cac")
        return view
    }()
    
    /// 关注
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.colorWithHexString("7b9cac")
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    /// 个性签名
    private lazy var sayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.textColor = UIColor.colorWithHexString("444444")
        label.font = UIFont.systemFontOfSize(18)
        return label
    }()
    
    /// 关注按钮
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "bierenziliao_icon_guanzhu"), forState: .Normal)
        button.setTitleColor(UIColor.colorWithHexString("41ca61"), forState: .Normal)
        button.addTarget(self, action: #selector(didTappedFollowButton), forControlEvents: .TouchUpInside)
        button.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).CGColor
        button.layer.borderWidth = 0.5
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()

}
