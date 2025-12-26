from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _


class CustomUser(AbstractUser):
    """自定义用户模型，继承自AbstractUser"""
    
    # 添加自定义字段
    nickname = models.CharField(_('昵称'), max_length=50, blank=True, null=True)
    avatar = models.ImageField(_('头像'), upload_to='avatars/', blank=True, null=True)
    bio = models.TextField(_('个人简介'), max_length=500, blank=True, null=True)
    
    # 性别选项
    GENDER_CHOICES = (
        ('M', _('男')),
        ('F', _('女')),
        ('O', _('其他')),
    )
    gender = models.CharField(_('性别'), max_length=1, choices=GENDER_CHOICES, blank=True, null=True)
    
    # 生日
    birthday = models.DateField(_('生日'), blank=True, null=True)
    
    # 地区
    location = models.CharField(_('地区'), max_length=100, blank=True, null=True)
    
    # 兴趣标签 - 使用JSONField存储数组
    interests = models.JSONField(_('兴趣标签'), blank=True, null=True)
    
    # 粉丝数和关注数
    followers_count = models.IntegerField(_('粉丝数'), default=0)
    following_count = models.IntegerField(_('关注数'), default=0)
    
    class Meta:
        verbose_name = _('用户')
        verbose_name_plural = _('用户')
    
    def __str__(self):
        return self.username