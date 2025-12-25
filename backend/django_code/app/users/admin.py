from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.translation import gettext_lazy as _
from .models.models import CustomUser


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    """自定义用户管理界面"""
    
    # 在列表页显示的字段
    list_display = ('username', 'email', 'nickname', 'gender', 'location', 'is_staff', 'is_active')
    
    # 搜索字段
    search_fields = ('username', 'email', 'nickname', 'location')
    
    # 过滤器字段
    list_filter = ('is_staff', 'is_active', 'groups')
    
    # 详情页字段分组
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        (_('Personal info'), {
            'fields': ('first_name', 'last_name', 'email', 'nickname', 'avatar', 'bio', 
                      'gender', 'birthday', 'location', 'interests'),
        }),
        (_('Permissions'), {
            'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions'),
        }),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    
    # 添加用户时的字段
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'nickname', 'gender', 'password1', 'password2', 'is_staff', 'is_active'),
        }),
    )